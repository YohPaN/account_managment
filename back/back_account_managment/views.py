import json

from back_account_managment.models import (
    Account,
    AccountCategory,
    AccountUser,
    AccountUserPermission,
    Category,
    Item,
    Profile,
    Transfert,
)
from back_account_managment.permissions import (
    IsAccountContributor,
    IsAccountOwner,
    IsOwner,
    LinkItemUserPermission,
    ManageRessourcePermission,
    TransfertToAccountPermission,
)
from back_account_managment.serializers.account_category_serializer import (
    AccountCategorySerializer,
)
from back_account_managment.serializers.account_serializer import (
    AccountListSerializer,
    AccountSerializer,
    AccountUserPermissionsSerializer,
    MinimalAccountSerilizer,
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
    ProfileSerializer,
    RegisterUserSerializer,
    UserSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password, make_password
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.db.models import Exists, OuterRef
from django.shortcuts import get_object_or_404
from rest_framework import permissions, status
from rest_framework.decorators import action
from rest_framework.permissions import SAFE_METHODS
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet

User = get_user_model()


class UserView(ModelViewSet):
    queryset = User.objects.all()
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
        new_password = request.data["new_password"]

        if check_password(request.data["old_password"], user.password):
            user.password = make_password(new_password)
            user.save()

            return Response(status=status.HTTP_200_OK)

        return Response(status=status.HTTP_401_UNAUTHORIZED)


class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        user_serializer = RegisterUserSerializer(data=request.data)

        if user_serializer.is_valid():
            user_validated_data = user_serializer.validated_data
            user = User(**user_validated_data)

            password = user_serializer.validated_data.get("password", None)

            if password is None:
                return Response(status=status.HTTP_400_BAD_REQUEST)

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
        "account_categories",
    ).all()
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
        account = get_object_or_404(Account, user=request.user, is_main=True)

        serializer = self.get_serializer(account)

        return Response(data=serializer.data, status=status.HTTP_200_OK)

    def create(self, request):
        serializer = MinimalAccountSerilizer(
            data={**request.data, "user": request.user.id}
        )

        if serializer.is_valid():
            account = serializer.save()

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
                data=self.get_serializer(account).data,
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
            data=self.get_serializer(account).data, status=status.HTTP_200_OK
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
            data=self.get_serializer(account).data, status=status.HTTP_200_OK
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
        to_account = self.request.data.get("to_account", None)

        user = get_object_or_404(User, username=username) if username else None

        item = serializer.save(
            account=account,
            user=user,
        )

        if to_account:
            Transfert.objects.create(item=item, to_account_id=to_account)

    def perform_update(self, serializer):
        username = self.request.data.get("username", None)
        to_account = self.request.data.get("to_account", None)

        user = get_object_or_404(User, username=username) if username else None
        category_id = self.request.data.get("category_id", None)

        item = serializer.save(
            category_id=category_id,
            user=user,
        )

        if to_account:
            Transfert.objects.update_or_create(
                item=item, defaults={"to_account_id": to_account}
            )

        else:
            transfert = Transfert.objects.filter(item=item).first()

            if transfert:
                transfert.delete()


class AccountUserView(ModelViewSet):
    queryset = AccountUser.objects.select_related(
        "account", "account__user"
    ).all()
    serializer_class = AccountUserSerializer
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    def get_queryset(self):
        return self.queryset.filter(state="PENDING", user=self.request.user)

    @action(methods=["get"], detail=False, url_path="count")
    def count(self, request):
        queryset = self.get_queryset()
        ask = queryset.count()

        return Response(
            {"pending_account_request": ask}, status=status.HTTP_200_OK
        )


class AccountUserPermissionView(ModelViewSet):
    serializer_class = AccountUserPermissionsSerializer
    permission_classes = [permissions.IsAuthenticated, IsAccountOwner]

    def get_queryset(self):
        return AccountUser.objects.get(
            user=User.objects.get(username=self.kwargs.get("user_username")),
            account=self.kwargs.get("account_id"),
        )

    def list(self, request, *args, **kwargs):
        queryset = Permission.objects.filter(
            Exists(
                AccountUserPermission.objects.filter(
                    account_user=self.get_queryset(),
                    permissions=OuterRef("pk"),
                )
            )
        )
        codenames = [entry.codename for entry in queryset]
        return Response({"permissions": codenames})

    def create(self, request, *args, **kwargs):
        account = Account.objects.get(pk=kwargs["account_id"])

        self.check_object_permissions(request, account)

        account_user = self.get_queryset()

        account_user_permissions, created = (
            AccountUserPermission.objects.get_or_create(
                account_user=account_user,
                permissions=Permission.objects.get(
                    codename=self.request.data["permission"]
                ),
            )
        )

        if not created:
            account_user_permissions.delete()

        return Response(
            data={"enabled": created},
            status=status.HTTP_200_OK,
        )


class CategoryView(ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()

    def get_queryset(self):
        if self.request.method not in SAFE_METHODS:
            return super().get_queryset()

        account_id = self.request.query_params.get("account", None)
        category = self.request.query_params.get("category", None)

        queryset = self.queryset

        match category:
            case "default":
                return queryset.filter(content_type=None)

            case "user":
                return queryset.filter(
                    content_type=ContentType.objects.get_for_model(User),
                    object_id=self.request.user.pk,
                )

            case "account":
                return queryset.filter(
                    content_type=ContentType.objects.get_for_model(Account),
                    object_id=account_id,
                )

            case "account_categories":
                account = Account.objects.get(pk=account_id)

                return queryset.filter(
                    Exists(
                        AccountCategory.objects.filter(
                            account=account, category=OuterRef("pk")
                        )
                    )
                )

            case _:
                return None

    def get_serializer_class(self):
        if self.request.method == "PUT":
            return CategoryWriteSerializer

        return super().get_serializer_class()

    @action(methods=["get"], detail=False, url_path="default")
    def get_defaut_categories(self, *args, **kwargs):
        default_category = Category.objects.filter(content_type=None)

        return Response(
            data=self.get_serializer(default_category, many=True).data,
            status=status.HTTP_200_OK,
        )

    def create(self, request, *args, **kwargs):
        account_id = request.data.get("account_id", None)

        request.data["icon"] = json.loads(request.data["icon"])

        if account_id is not None:
            request.data["object_id"] = account_id
            request.data["content_type"] = ContentType.objects.get_for_model(
                Account
            ).pk
        else:
            request.data["object_id"] = str(request.user.pk)
            request.data["content_type"] = ContentType.objects.get_for_model(
                User
            ).pk
        return super().create(request, *args, **kwargs)

    def perform_create(self, serializer):
        category = serializer.save()

        if category.content_type.model_class() is Account:
            AccountCategory.objects.create(
                category=category, account_id=category.object_id
            )

    def update(self, request, *args, **kwargs):
        request.data["icon"] = json.loads(request.data["icon"])

        return super().update(request, *args, **kwargs)


class AccountCategoryView(ModelViewSet):
    queryset = AccountCategory.objects.all()
    serializer_class = AccountCategorySerializer

    def create(self, request):
        try:
            category = Category.objects.get(
                pk=request.data.get("category", None)
            )

            account = Account.objects.get(pk=request.data.get("account", None))

            if category.content_type == ContentType.objects.get_for_model(
                Account
            ):
                account_category = AccountCategory.objects.filter(
                    category=category
                )

                if (
                    account_category.exists()
                    and account_category.first().account != account
                ):
                    return Response(
                        {"detail": "The category is link to another account"},
                        status=status.HTTP_401_UNAUTHORIZED,
                    )

            AccountCategory.objects.get_or_create(
                account=account, category=category
            )

            return Response(
                data=CategoryWriteSerializer(category).data,
                status=status.HTTP_201_CREATED,
            )
        except Category.DoesNotExist as e:
            return Response(
                {"error": str(e)}, status=status.HTTP_404_NOT_FOUND
            )

        except Account.DoesNotExist as e:
            return Response(
                {"error": str(e)}, status=status.HTTP_404_NOT_FOUND
            )

    @action(methods=["post"], detail=False, url_path="unlink")
    def unlink(self, request):
        try:
            category = Category.objects.get(
                pk=request.data.get("category", None)
            )

            account = Account.objects.get(pk=request.data.get("account", None))

            AccountCategory.objects.filter(
                account=account, category=category
            ).delete()

            return Response(
                status=status.HTTP_204_NO_CONTENT,
            )
        except Category.DoesNotExist as e:
            return Response(
                {"error": str(e)}, status=status.HTTP_404_NOT_FOUND
            )

        except Account.DoesNotExist as e:
            return Response(
                {"error": str(e)}, status=status.HTTP_404_NOT_FOUND
            )
