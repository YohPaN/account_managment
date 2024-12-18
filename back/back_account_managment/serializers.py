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
        fields = ["user", "first_name", "last_name", "salary"]


class RegisterUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username", "email", "password"]


class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ["username", "email", "profile"]


class UserAccountUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username"]


class ItemWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["title", "description", "valuation", "account"]
        read_only_fields = ["account"]


class ItemReadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["id", "title", "description", "valuation", "account"]
        read_only_fields = ["account"]


class AccountUserSerializer(serializers.ModelSerializer):
    user = UserAccountUserSerializer()

    class Meta:
        model = AccountUser
        fields = ["user", "state"]


class AccountSerializer(serializers.ModelSerializer):
    items = ItemReadSerializer(many=True)
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
                "owner",
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
        fields = ["name", "user"]


class AccountUserPermissionsSerializer(serializers.Serializer):
    permissions_codename = serializers.SerializerMethodField()

    class Meta:
        model = AccountUserPermission
        fields = ["permissions"]

    def get_permissions_codename(self, obj):
        return obj.permissions.codename
