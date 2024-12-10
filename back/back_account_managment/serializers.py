from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
    Profile,
)
from django.contrib.auth import get_user_model
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
        try:
            user = self.context["request"].user
        except KeyError:
            raise KeyError("There is no request attach on context")

        if account.user == user:
            return [
                "view_account",
                "add_account",
                "change_account",
                "delete_account",
            ]

        try:
            account_user = AccountUser.objects.get(user=user, account=account)
        except AccountUser.DoesNotExist:
            raise AccountUser.DoesNotExist(
                "The user isn't a contributor of the account"
            )

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
