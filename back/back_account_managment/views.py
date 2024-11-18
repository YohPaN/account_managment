import json

from back_account_managment import models
from back_account_managment.models import Account, AccountUser
from back_account_managment.permissions import IsOwner
from back_account_managment.serializers import (
    AccountSerializer,
    ItemSerializer,
    ManageAccountSerializer,
    UserSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password, make_password
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
    permission_classes = [permissions.IsAuthenticated]

    @action(detail=False, methods=["get"], url_path="me")
    def get_current_user(self, request):
        user = request.user
        serializer = self.serializer_class(user)
        return Response(serializer.data)

    @action(detail=False, methods=["patch"], url_path="me/update")
    def update_current_user(self, request):
        user = request.user
        profile = user.profile

        user.username = request.data["username"]
        user.password = request.data["password"]
        user.email = request.data["email"]
        user.save()

        profile.first_name = request.data["first_name"]
        profile.last_name = request.data["last_name"]
        profile.salary = request.data["salary"]
        profile.save()

        serializer = self.serializer_class(user)

        return Response(status=status.HTTP_200_OK, data=serializer.data)

    @action(detail=False, methods=["patch"], url_path="password")
    def update_password(self, request):
        user = request.user
        old_password = request.data["old_password"]
        new_password = request.data["new_password"]

        if check_password(old_password, user.password):
            user.password = make_password(new_password)
            user.save()

            return Response(status=status.HTTP_200_OK)

        else:
            return Response(status=status.HTTP_401_UNAUTHORIZED)


class ProfileView(ModelViewSet):
    queryset = models.Profile.objects.all()
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request):
        user = request.user
        serializer = UserSerializer(user)

        return Response(serializer.data, status=status.HTTP_200_OK)

    def patch(self, request):
        data = request.data
        user = request.user

        try:
            user.username = data.get("username", user.username)
            user.email = data.get("email", user.email)
            user.save()

            # Update profile fields
            profile = models.Profile.objects.get(user=user)
            profile.first_name = data.get("first_name", profile.first_name)
            profile.last_name = data.get("last_name", profile.last_name)
            profile.salary = data.get("salary", profile.salary)
            profile.save()

            return Response(status=status.HTTP_200_OK)
        except Exception:
            return Response(status=status.HTTP_400_BAD_REQUEST)


class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        data = request.data

        try:
            user = User.objects.create_user(
                username=data["username"],
                email=data["email"],
            )
            user.set_password(data["password"]),

            profile = models.Profile.objects.create(
                first_name=data["first_name"],
                last_name=data["last_name"],
                salary=data["salary"],
                user=user,
            )

            account = models.Account.objects.create(
                name="my account", user=user, is_main=True
            )

            user.save()
            profile.save()
            account.save()

            return Response(status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)


class ItemView(ModelViewSet):
    queryset = models.Item.objects.all()
    serializer_class = ItemSerializer


class AccountView(ModelViewSet):
    queryset = models.Account.objects.all()
    serializer_class = AccountSerializer
    permission_classes = [IsOwner]

    def list(self, request):
        contributor_account_user = AccountUser.objects.filter(
            account=OuterRef("pk"), user=request.user
        )

        own_accounts = Account.objects.filter(user=request.user)

        contributor_accounts = Account.objects.filter(Exists(contributor_account_user))

        own_account_serialized = self.serializer_class(own_accounts, many=True)
        contributor_account_serialized = self.serializer_class(
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
            account = Account.objects.filter(user=user).first()
        except models.Account.DoesNotExist:
            return Response(
                {"detail": "Account not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = self.serializer_class(account)

        return Response(data=serializer.data, status=status.HTTP_200_OK)

        try:
            account = Account.objects.get(pk=pk)
        except models.Account.DoesNotExist:
            return Response(
                {"detail": "Account not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        items = account.items()

        serializer = ItemSerializer(items, many=True)

        return Response(serializer.data, status=status.HTTP_200_OK)

    def create(self, request, *args, **kwargs):
        data = {"name": request.data["name"], "user": request.user.id}
        serializer = ManageAccountSerializer(data=data)

        if serializer.is_valid():
            new_account = serializer.save()

            account = Account.objects.get(pk=new_account.id)

            contributors = json.loads(request.data["contributors"])

            for contributor in contributors:
                if contributor != request.user.username:
                    AccountUser.objects.create(
                        account=account,
                        user=User.objects.get(username=contributor),
                    )

            return Response(status=status.HTTP_201_CREATED)

        # Return errors if validation fails
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def partial_update(self, request, pk):
        data = request.data
        account = Account.objects.get(pk=pk)

        account.name = data["name"]
        account.save()

        user_contributors = User.objects.filter(
            username__in=json.loads(data["contributors"])
        ).exclude(username=request.user.username)

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
            new_account_user = AccountUser.objects.create(
                user=User.objects.get(username=contributor), account=account
            )
            new_account_user.save()

        for contributor in contributor_to_remove:
            AccountUser.objects.filter(
                user=User.objects.get(username=contributor), account=account
            ).delete()

        return Response(status=status.HTTP_201_CREATED)

    def destroy(self, request, pk):
        account = Account.objects.filter(pk=pk, is_main=False)

        if account.exists():
            account.delete()
            return Response(status=status.HTTP_200_OK)

        return Response(
            data={"error": "You can't delete your main account"},
            status=status.HTTP_401_UNAUTHORIZED,
        )
