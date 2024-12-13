import json

from back_account_managment.models import Account, AccountUser, Item
from back_account_managment.permissions import CRUDPermission, IsOwner
from back_account_managment.serializers import (
    AccountSerializer,
    ItemSerializer,
    ManageAccountSerializer,
    ProfileSerializer,
    RegisterUserSerializer,
    UserSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password
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
        serializer = self.get_serializer(
            request.user, data=request.data, partial=True
        )
        if serializer.is_valid():
            serializer.save()
            return Response(
                serializer.validated_data, status=status.HTTP_201_CREATED
            )

        return Response(status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=["patch"], url_path="password")
    def update_password(self, request):
        user = request.user
        new_password = request.data["new_password"]

        if check_password(request.data["old_password"], user.password):
            user.set_password(new_password)

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

                return Response(status=status.HTTP_201_CREATED)

            else:
                user.delete()

        return Response(status=status.HTTP_400_BAD_REQUEST)


class AccountView(ModelViewSet):
    queryset = Account.objects.all()
    serializer_class = AccountSerializer
    permission_classes = [permissions.IsAuthenticated, CRUDPermission]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context.update({"request": self.request})
        return context

    def list(self, request):
        contributor_account_user = AccountUser.objects.filter(
            account=OuterRef("pk"), user=request.user
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
        if not instance.is_main:
            instance.delete()


class ItemView(ModelViewSet):
    serializer_class = ItemSerializer
    queryset = Item.objects.all()
    permission_classes = [permissions.IsAuthenticated, CRUDPermission]

    def perform_create(self, serializer):
        account = Account.objects.get(
            pk=self.kwargs.get("account_id"),
        )

        serializer.save(account=account)
