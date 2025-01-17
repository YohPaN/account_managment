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
    UserCategory,
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
    queryset = User.objects.prefetch_related("user_categories__category").all()
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
    queryset = Account.objects.all()
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
        contributor_account_user = AccountUser.objects.filter(
            account=OuterRef("pk"), user=request.user, state="APPROVED"
        )
        own_accounts = Account.objects.filter(user=request.user)

        contributor_accounts = Account.objects.filter(
            Exists(contributor_account_user)
        )

        own_account_serialized = AccountListSerializer(own_accounts, many=True)
        own_account_serialized.context.update({"request": self.request})
        contributor_account_serialized = AccountListSerializer(
            contributor_accounts, many=True
        )
        contributor_account_serialized.context.update(
            {"request": self.request}
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

            for contributor in json.loads(request.data["contributors"]):
                if contributor != request.user.username:
                    AccountUser.objects.create(
                        account=account,
                        user=User.objects.get(username=contributor),
                    )

            return Response(status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def partial_update(self, request, pk):
        account = Account.objects.get(pk=pk)

        serializer = MinimalAccountSerilizer(
            account, data=request.data, partial=True
        )

        if serializer.is_valid():
            serializer.save()

        user_contributors = User.objects.filter(
            username__in=json.loads(request.data["contributors"])
        ).exclude(username=account.user.username)

        account_users = AccountUser.objects.filter(account=account)
        account_user_set = set(
            account_user.user.username for account_user in account_users
        )
        user_contributors_set = set(
            user_contributor.username for user_contributor in user_contributors
        )

        contributor_to_remove = account_user_set - user_contributors_set
        contributor_to_add = user_contributors_set - account_user_set

        for contributor in contributor_to_add:
            AccountUser.objects.create(
                user=User.objects.get(username=contributor), account=account
            )

        for contributor in contributor_to_remove:
            AccountUser.objects.filter(
                user=User.objects.get(username=contributor), account=account
            ).delete()

        return Response(status=status.HTTP_201_CREATED)

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

            return Response(status=status.HTTP_200_OK)

        return Response(
            {"error": "You must include 'split' field"},
            status=status.HTTP_400_BAD_REQUEST,
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
        category_id = self.request.data.get("category_id", None)

        user = get_object_or_404(User, username=username) if username else None
        category = get_object_or_404(Category, pk=category_id)

        item = serializer.save(
            category=category,
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
    queryset = AccountUser.objects.all()
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

        permissions_to_remove = AccountUserPermission.objects.exclude(
            account_user=account_user,
            permissions__codename__in=request.data["permissions"],
        ).filter(account_user=account_user)

        for account_user_permission in permissions_to_remove:
            account_user_permission.delete()

        for permission_codename in json.loads(request.data["permissions"]):
            permission = Permission.objects.get(codename=permission_codename)

            AccountUserPermission.objects.get_or_create(
                account_user=account_user,
                permissions=permission,
            )

        return Response(status=status.HTTP_200_OK)


class CategoryView(ModelViewSet):
    serializer_class = CategorySerializer
    queryset = Category.objects.all()

    def get_queryset(self):
        if self.request.method not in SAFE_METHODS:
            return super().get_queryset()

        account_id = self.request.data.get("account_id", None)
        account_category = None
        user_category = None

        default_category = Category.objects.filter(content_type=None)

        if account_id is not None:
            account = Account.objects.get(pk=account_id)

        account_category = Category.objects.filter(
            Exists(
                AccountCategory.objects.filter(
                    account_id=account_id, category=OuterRef("pk")
                )
            )
        )

        if account_id is None or self.request.user == account.user:
            user_category = Category.objects.filter(
                Exists(
                    UserCategory.objects.filter(
                        user=self.request.user, category=OuterRef("pk")
                    )
                )
            )

            queryset = default_category | account_category | user_category

        else:
            queryset = default_category | account_category

        return queryset

    def get_serializer_class(self):
        if self.request.method == "PUT":
            return CategoryWriteSerializer

        return super().get_serializer_class()

    def create(self, request, *args, **kwargs):
        account_id = request.data.get("account_id", None)

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
