import json

from back_account_managment.models import Account, AccountUser, Item, Profile
from back_account_managment.permissions import (
    CanCreate,
    CanDelete,
    CanUpdate,
    IsContributor,
    IsOwner,
)
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
    permission_classes = [IsOwner, permissions.IsAuthenticated]

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
    queryset = Profile.objects.all()
    permission_classes = [IsOwner, permissions.IsAuthenticated]

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
            profile = Profile.objects.get(user=user)
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

            profile = Profile.objects.create(
                first_name=data["first_name"],
                last_name=data["last_name"],
                salary=(
                    float(data["salary"]) if data["salary"] != "" else None
                ),
                user=user,
            )

            account = Account.objects.create(
                name="my account", user=user, is_main=True
            )

            user.save()
            profile.save()
            account.save()

            return Response(status=status.HTTP_201_CREATED)
        except Exception as e:
            return Response(
                {"error": str(e)}, status=status.HTTP_400_BAD_REQUEST
            )


class ItemView(ModelViewSet):
    queryset = Item.objects.all()
    serializer_class = ItemSerializer
    permission_classes = [IsOwner, permissions.IsAuthenticated]


class AccountView(ModelViewSet):
    queryset = Account.objects.all()
    serializer_class = AccountSerializer
    permission_classes = [
        permissions.IsAuthenticated,
    ]

    permission_by_method = {
        "get": (IsOwner | IsContributor),
        "post": (IsOwner | CanCreate),
        "patch": (IsOwner | CanUpdate),
        "delete": (IsOwner | CanDelete),
    }

    def get_permissions(self):
        if self.request.method not in permissions.SAFE_METHODS:
            self.permission_classes.append(
                self.permission_by_method[self.request.method.lower()]
            )

        return [permission() for permission in self.permission_classes]

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
            account = Account.objects.filter(user=user).first()
        except Account.DoesNotExist:
            return Response(
                {"detail": "Account not found."},
                status=status.HTTP_404_NOT_FOUND,
            )

        serializer = self.get_serializer(account)

        return Response(data=serializer.data, status=status.HTTP_200_OK)

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

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def partial_update(self, request, pk):
        data = request.data
        account = Account.objects.get(pk=pk)

        account.name = data["name"]
        account.save()

        user_contributors = User.objects.filter(
            username__in=json.loads(data["contributors"])
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

    @action(detail=True, methods=["post"], url_path="items")
    def create_or_update_item(self, request, pk=None):
        account = self.get_object()

        data = request.data
        item_id = data.get("item_id", None)

        if item_id is not None and item_id != "":
            item = Item.objects.get(pk=item_id)
            item.title = data["title"]
            item.description = data["description"]
            item.valuation = data["valuation"]
            item.save()

        else:
            Item.objects.create(
                account=account,
                title=data["title"],
                description=data["description"],
                valuation=data["valuation"],
            )

        return Response(status=status.HTTP_201_CREATED)

    @action(
        detail=True, methods=["delete"], url_path="items/(?P<item_id>[^/.]+)"
    )
    def delete_item(self, request, pk=None, item_id=None):
        item = Item.objects.get(pk=item_id)
        item.delete()

        return Response(status=status.HTTP_200_OK)
