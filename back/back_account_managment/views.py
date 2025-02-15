from decimal import Decimal

from back_account_managment.models import (
    Account,
    AccountUser,
    Category,
    Item,
    Profile,
)
from back_account_managment.permissions import (
    IsAccountContributor,
    IsAccountOwner,
    IsOwner,
    LinkItemUserPermission,
    ManageRessourcePermission,
    TransfertToAccountPermission,
)
from back_account_managment.serializers.account_serializer import (
    AccountListSerializer,
    AccountSerializer,
    ContributorAccountSerilizer,
    MinimalAccountSerilizer,
    SalaryBasedSplitAccountSerilizer,
)
from back_account_managment.serializers.account_user_permission_serializer import (  # noqa
    AccountUserPermissionsSerializer,
)
from back_account_managment.serializers.account_user_serializer import (
    AccountUserSerializer,
)
from back_account_managment.serializers.category_serializer import (
    CategorySerializer,
    CategoryWriteSerializer,
)
from back_account_managment.serializers.item_serializer import (
    ItemWriteSerializer,
)
from back_account_managment.serializers.user_serializer import (
    PasswordUserSerializer,
    ProfileSerializer,
    RegisterUserSerializer,
    UserSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password, make_password
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.db.models import DecimalField, Exists, F, OuterRef, Sum, Value
from django.db.models.functions import Coalesce
from django.shortcuts import get_object_or_404
from rest_framework import permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet

User = get_user_model()


class UserView(ModelViewSet):
    queryset = User.objects.select_related("profile").prefetch_related(
        "categories"
    )
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwner]

    @action(detail=False, methods=["get"], url_path="me")
    def get_current_user(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=["patch"], url_path="me/update")
    def update_current_user(self, request):
        user_serializer = self.get_serializer(
            request.user, data=request.data, partial=True
        )

        profile = get_object_or_404(Profile, user=request.user)

        profile_serializer = ProfileSerializer(
            profile, data=request.data, partial=True
        )

        if user_serializer.is_valid():
            user_serializer.save()

            if profile_serializer.is_valid():
                profile_serializer.save()

                return Response(
                    user_serializer.validated_data,
                    status=status.HTTP_201_CREATED,
                )

        return Response(status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=["patch"], url_path="password")
    def update_password(self, request):
        user = request.user
        serializer = PasswordUserSerializer(data=request.data)

        if serializer.is_valid() and check_password(
            serializer.validated_data["old_password"], user.password
        ):
            user.password = make_password(
                serializer.validated_data["new_password"]
            )
            user.save()

            return Response(status=status.HTTP_200_OK)

        return Response(status=status.HTTP_401_UNAUTHORIZED)


class RegisterView(APIView):
    serializer_class = RegisterUserSerializer
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = self.serializer_class(data=request.data)

        if serializer.is_valid():
            password = serializer.validated_data.get("password", None)

            if password is None:
                return Response(status=status.HTTP_400_BAD_REQUEST)

            user = serializer.save()
            user.set_password(password)
            user.save()

            profile_serializer = ProfileSerializer(
                data={"user": user.pk, **request.data}
            )

            if profile_serializer.is_valid():
                profile_serializer.save()

                Account.objects.create(
                    name="Main account", user=user, is_main=True
                )

                return Response(status=status.HTTP_201_CREATED)

            else:
                user.delete()

        return Response(status=status.HTTP_400_BAD_REQUEST)


class AccountView(ModelViewSet):
    queryset = Account.objects.prefetch_related(
        "items",
        "categories",
        "transfer_items",
        "contributors",
    ).annotate(
        total=Coalesce(
            Sum(
                F("items__valuation") + F("transfer_items__item__valuation"),
            ),
            Value(0),
            output_field=DecimalField(),
        )
    )
    serializer_class = AccountSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        IsOwner | (IsAccountContributor & ManageRessourcePermission),
    ]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context.update({"request": self.request})
        return context

    def list(self, request):
        queryset = self.get_queryset()

        own_accounts = queryset.filter(user=request.user)

        contributor_account_user = AccountUser.objects.filter(
            account=OuterRef("pk"), user=request.user, state="APPROVED"
        )
        contributor_accounts = queryset.filter(
            Exists(contributor_account_user)
        )

        own_account_serialized = AccountListSerializer(
            own_accounts,
            many=True,
            context={"request": request},
        )

        contributor_account_serialized = AccountListSerializer(
            contributor_accounts,
            many=True,
            context={"request": request},
        )

        return Response(
            data={
                "own": own_account_serialized.data,
                "contributor_account": contributor_account_serialized.data,
            },
            status=status.HTTP_200_OK,
        )

    @action(detail=False, methods=["get"], url_path="me")
    def get_current_user_account(self, request, pk=None):
        account = self.get_queryset().get(user=request.user, is_main=True)
        serializer = self.get_serializer(account)

        return Response(data=serializer.data, status=status.HTTP_200_OK)

    def create(self, request):
        serializer = MinimalAccountSerilizer(
            data={**request.data, "user": request.user.id}
        )

        if serializer.is_valid():
            account = serializer.save()
            account.total = Decimal(0)

            return Response(
                data=self.get_serializer(account).data,
                status=status.HTTP_201_CREATED,
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def partial_update(self, request, pk):
        account = Account.objects.get(pk=pk)

        serializer = MinimalAccountSerilizer(
            account, data=request.data, partial=True
        )

        if serializer.is_valid():
            serializer.save()

        return Response(data=serializer.data, status=status.HTTP_201_CREATED)

    def destroy(self, request, pk):
        account = self.get_object()

        if not account.is_main:
            account.delete()

            return Response(status=status.HTTP_204_NO_CONTENT)

        return Response(
            {"error": "You can't delete your main account"},
            status=status.HTTP_403_FORBIDDEN,
        )

    @action(detail=True, methods=["post"], url_path="split")
    def set_salary_based_split(self, request, pk=None):
        account = get_object_or_404(Account, pk=pk)

        split = request.data.get("is_slit", None)

        if split is not None:
            try:
                split = eval(split)
            except NameError:
                return Response(
                    {"error": "The 'split' field must represent a bool value"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if split is True:
                account_users = AccountUser.objects.filter(
                    account=account,
                    state="APPROVED",
                )

                for account_user in account_users:
                    profile = Profile.objects.get(
                        user=User.objects.get(pk=account_user.user.pk)
                    )

                    if profile.salary is None:
                        return Response(
                            {
                                "error": "All user in account must have set their salary"  # noqa
                            },
                            status=status.HTTP_401_UNAUTHORIZED,
                        )

            account.salary_based_split = split
            account.save()

            return Response(
                data=SalaryBasedSplitAccountSerilizer(account).data,
                status=status.HTTP_200_OK,
            )

        return Response(
            {"error": "You must include 'split' field"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    @action(detail=True, methods=["post"], url_path="contributors/add")
    def update_contributors(self, request, pk=None):
        account = self.get_object()

        contributor_to_add = request.data.get("user_username", None)

        if contributor_to_add == account.user.username:
            return Response(
                {"error": "You can't add yourself as a contributor"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        if AccountUser.objects.filter(
            account=account, user__username=contributor_to_add
        ).exists():
            return Response(
                {"error": f"{contributor_to_add} is already a contributor"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = User.objects.filter(username=contributor_to_add)

        if not user.exists():
            return Response(
                {"error": f"{contributor_to_add} doesn't exist"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        AccountUser.objects.create(user=user.first(), account=account)

        return Response(
            data=ContributorAccountSerilizer(account).data,
            status=status.HTTP_200_OK,
        )

    @action(detail=True, methods=["post"], url_path="contributors/remove")
    def remove_contributors(self, request, pk=None):
        account = self.get_object()

        contributor_to_remove = request.data.get("user_username", None)

        if not AccountUser.objects.filter(
            account=account, user__username=contributor_to_remove
        ).exists():
            return Response(
                {"error": f"{contributor_to_remove} is not a contributor"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = User.objects.filter(username=contributor_to_remove)

        if not user.exists():
            return Response(
                {"error": f"{contributor_to_remove} doesn't exist"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        AccountUser.objects.get(user=user.first(), account=account).delete()

        return Response(
            data=ContributorAccountSerilizer(account).data,
            status=status.HTTP_200_OK,
        )


class ItemView(ModelViewSet):
    serializer_class = ItemWriteSerializer
    queryset = Item.objects.all()
    permission_classes = [
        permissions.IsAuthenticated,
        (
            IsAccountOwner
            | (
                IsAccountContributor
                & (IsOwner | ManageRessourcePermission)
                & LinkItemUserPermission
            )
        ),
        TransfertToAccountPermission,
    ]

    def perform_create(self, serializer):
        account = Account.objects.get(
            pk=self.kwargs.get("account_id"),
        )

        username = self.request.data.get("username", None)
        user = get_object_or_404(User, username=username) if username else None

        item = serializer.save(
            account=account,
            user=user,
        )

        item.manage_transfert(self.request.data.get("to_account", None))

    def perform_update(self, serializer):
        username = self.request.data.get("username", None)
        user = get_object_or_404(User, username=username) if username else None

        category_id = self.request.data.get("category_id", None)

        item = serializer.save(
            category_id=category_id,
            user=user,
        )

        item.manage_transfert(self.request.data.get("to_account", None))


class AccountUserView(ModelViewSet):
    queryset = AccountUser.objects.select_related("account", "account__user")
    serializer_class = AccountUserSerializer
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def get_queryset(self):
        return self.queryset.filter(state="PENDING", user=self.request.user)


class AccountUserPermissionView(ModelViewSet):
    serializer_class = AccountUserPermissionsSerializer
    permission_classes = [permissions.IsAuthenticated, IsAccountOwner]

    def get_queryset(self):
        return AccountUser.objects.prefetch_related("permissions").get(
            user=User.objects.get(username=self.kwargs.get("user_username")),
            account=self.kwargs.get("account_id"),
        )

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()

        permissions = queryset.permissions.all()

        codenames = [permission.codename for permission in permissions]
        return Response({"permissions": codenames})

    def create(self, request, *args, **kwargs):
        account = Account.objects.get(pk=kwargs["account_id"])

        self.check_object_permissions(request, account)

        account_user = self.get_queryset()

        codename = self.request.data["permission"]

        try:
            account_user_permission = account_user.permissions.get(
                codename=codename,
            )

            account_user.permissions.remove(account_user_permission)
            created = False

        except Permission.DoesNotExist:
            account_user.permissions.add(
                Permission.objects.get(codename=codename)
            )
            created = True

        return Response(
            data={"enabled": created},
            status=status.HTTP_200_OK,
        )


class CategoryView(ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()

    def list(self, request, *args, **kwargs):
        account_id = self.request.query_params.get("account", None)
        category = self.request.query_params.get("category", None)

        queryset = self.get_queryset()

        match category:
            case "default":
                queryset = queryset.filter(content_type=None)

            case "user":
                queryset = queryset.filter(
                    content_type=ContentType.objects.get_for_model(User),
                    object_id=self.request.user.pk,
                )

            case "account":
                queryset = queryset.filter(
                    content_type=ContentType.objects.get_for_model(Account),
                    object_id=account_id,
                )

            case "account_categories":
                account = Account.objects.get(pk=account_id)

                queryset = account.categories.all()

            case _:
                return Response(
                    {"detail": f"Type of category {category} does not exist"},
                    status=status.HTTP_404_NOT_FOUND,
                )

        return Response(
            self.get_serializer(queryset, many=True).data,
            status=status.HTTP_200_OK,
        )

    def create(self, request, *args, **kwargs):
        self.serializer_class = CategoryWriteSerializer
        model_name = request.data.get("content_type", None)

        content_type = ContentType.objects.get(model=model_name)

        if content_type.model_class() == User:
            request.data["object_id"] = str(request.user.pk)

        request.data["content_type"] = content_type.pk

        return super().create(request, *args, **kwargs)

    def perform_create(self, serializer):
        category = serializer.save()

        instance = category.content_object
        if isinstance(instance, Account):
            category.accounts.add(instance)


class AccountCategoryView(ModelViewSet):
    def create(self, request):
        account = get_object_or_404(
            Account, pk=request.data.get("account", None)
        )

        link = account.manage_category(
            category_id=request.data.get("category", None)
        )

        if link is True:
            return Response(status=status.HTTP_201_CREATED)

        return Response(link, status=status.HTTP_404_NOT_FOUND)

    @action(methods=["post"], detail=False, url_path="unlink")
    def unlink(self, request):
        account = get_object_or_404(
            Account, pk=request.data.get("account", None)
        )

        link = account.manage_category(
            category_id=request.data.get("category", None), link=False
        )

        if link is True:
            return Response(
                status=status.HTTP_204_NO_CONTENT,
            )

        return Response(link, status=status.HTTP_404_NOT_FOUND)
