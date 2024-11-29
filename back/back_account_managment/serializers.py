from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
    Profile,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from rest_framework import serializers

User = get_user_model()


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ["first_name", "last_name", "salary"]


class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ["username", "email", "password", "profile"]


class UserAccountUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username"]


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["id", "title", "description", "valuation", "account"]


class AccountUserSerializer(serializers.ModelSerializer):
    user = UserAccountUserSerializer()

    class Meta:
        model = AccountUser
        fields = ["user", "state"]


class AccountSerializer(serializers.ModelSerializer):
    items = ItemSerializer(many=True)
    contributors = AccountUserSerializer(many=True)

    permissions = serializers.SerializerMethodField()

    class Meta:
        model = Account
        fields = [
            "id",
            "name",
            "total",
            "is_main",
            "items",
            "contributors",
            "permissions",
        ]

    def get_permissions(self, account):
        user = self.context["request"].user

        if account.user != user:
            account_user = AccountUser.objects.get(user=user, account=account)

            account_user_permissions = AccountUserPermission.objects.filter(
                account_user=account_user
            )

            serializer = AccountUserPermissionsSerializer(
                account_user_permissions, many=True
            )

            return [
                permission["permissions_codename"]
                for permission in serializer.data
            ]

        return []


class ManageAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ["id", "name", "user"]


class AccountUserPermissionsSerializer(serializers.Serializer):
    permissions_codename = serializers.SerializerMethodField()

    class Meta:
        model = AccountUserPermission
        fields = ["permissions"]

    def get_permissions_codename(self, obj):
        return obj.permissions.codename
