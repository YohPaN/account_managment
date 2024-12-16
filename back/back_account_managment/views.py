import json

from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
    Profile,
)
from back_account_managment.permissions import (
    CRUDPermission,
    IsOwner,
    ManageAccountUserPermissions,
)
from back_account_managment.serializers import (
    AccountSerializer,
    AccountUserPermissionsSerializer,
    ItemWriteSerializer,
    ManageAccountSerializer,
    ProfileSerializer,
    RegisterUserSerializer,
    UserSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password, make_password
from django.contrib.auth.models import Permission
from django.db import IntegrityError
from django.db.models import Exists, OuterRef
from rest_framework import permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.viewsets import ModelViewSet

User = get_user_model()


class UserView(ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [IsOwner, permissions.IsAuthenticated]

    @action(detail=False, methods=["get"], url_path="me")
    def get_current_user(self, request):
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)

    @action(detail=False, methods=["patch"], url_path="me/update")
    def update_current_user(self, request):
        user_serializer = self.get_serializer(
            request.user, data=request.data, partial=True
        )

        try:
            profile = Profile.objects.get(user=request.user)
        except Profile.DoesNotExist:
            profile = None

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
        (IsOwner | CRUDPermission),
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

        own_account_serialized = self.get_serializer(own_accounts, many=True)
        contributor_account_serialized = self.get_serializer(
            contributor_accounts, many=True
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
        user = request.user

        try:
            account = Account.objects.get(user=user, is_main=True)
        except Account.DoesNotExist:
            return Response(
                {"detail": "Account not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = self.get_serializer(account)

        return Response(data=serializer.data, status=status.HTTP_200_OK)

    def create(self, request):
        serializer = ManageAccountSerializer(
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

        serializer = ManageAccountSerializer(
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

    def perform_destroy(self, instance):
        try:
            assert not instance.is_main
            instance.delete()
        except AssertionError:
            raise IntegrityError("You can't delete your main account !")


class ItemView(ModelViewSet):
    serializer_class = ItemWriteSerializer
    queryset = Item.objects.all()
    permission_classes = [
        permissions.IsAuthenticated,
        CRUDPermission,
    ]

    def perform_create(self, serializer):
        account = Account.objects.get(
            pk=self.kwargs.get("account_id"),
        )

        serializer.save(account=account)


class AccountUserPermissionView(ModelViewSet):
    serializer_class = AccountUserPermissionsSerializer
    permission_classes = [
        permissions.IsAuthenticated,
        ManageAccountUserPermissions,
    ]

    def list(self, request, *args, **kwargs):
        codenames = [entry.codename for entry in self.get_queryset()]
        return Response({"permissions": codenames})

    def get_queryset(self):
        try:
            account_user = AccountUser.objects.get(
                user=User.objects.get(
                    username=self.kwargs.get("user_username")
                ),
                account=self.kwargs.get("account_id"),
            )
        except AccountUser.DoesNotExist:
            raise AccountUser.DoesNotExist(
                "This user is not a contributor of this account"
            )

        return Permission.objects.filter(
            Exists(
                AccountUserPermission.objects.filter(
                    account_user=account_user, permissions=OuterRef("pk")
                )
            )
        )

    def create(self, request, *args, **kwargs):
        account_user = AccountUser.objects.get(
            user=User.objects.get(username=kwargs.get("user_username")),
            account=kwargs.get("account_id"),
        )

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
