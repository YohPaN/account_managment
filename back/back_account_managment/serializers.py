from decimal import Decimal

from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
    Profile,
)
from django.contrib.auth import get_user_model
from django.db.models import Sum
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
    user = UserAccountUserSerializer()

    class Meta:
        model = Item
        fields = ["id", "title", "description", "valuation", "account", "user"]
        read_only_fields = ["account"]


class AccountAccountUserSerializer(serializers.ModelSerializer):
    user = UserAccountUserSerializer()

    class Meta:
        model = AccountUser
        fields = ["user", "state"]


class UsernameUserSerilizer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username"]


class AccountListSerializer(serializers.ModelSerializer):
    items = ItemReadSerializer(many=True)
    contributors = AccountAccountUserSerializer(many=True)
    user = UsernameUserSerilizer()

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
            "user",
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


class AccountSerializer(serializers.ModelSerializer):
    items = ItemReadSerializer(many=True)
    contributors = AccountAccountUserSerializer(many=True)
    user = UsernameUserSerilizer()

    permissions = serializers.SerializerMethodField()

    own_contribution = serializers.SerializerMethodField()
    need_to_add = serializers.SerializerMethodField()

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
            "own_contribution",
            "need_to_add",
            "user",
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

    def get_own_contribution(self, account):
        try:
            user = self.context["request"].user
        except KeyError:
            raise KeyError("There is no request attach on context")

        total = Item.objects.filter(
            user=user, account=account, valuation__gt=0
        )
        if total.count() > 0:
            return total.aggregate(total=(Sum("valuation")))

        return {"total": Decimal(0.00)}

    def get_need_to_add(self, account):
        total = Item.objects.filter(account=account, valuation__lt=0)

        if total.count() > 0:
            total = total.aggregate(total=Sum("valuation"))

            user_part = total["total"] / (
                AccountUser.objects.filter(
                    account=account, state="APPROVED"
                ).count()
                + 1
            )

            return {
                "total": user_part
                + self.get_own_contribution(account=account)["total"]
            }

        return {"total": Decimal(0.00)}


class MinimalAccountSerilizer(serializers.ModelSerializer):
    user = UsernameUserSerilizer()

    class Meta:
        model = Account
        fields = ["name", "user"]


class AccountUserSerializer(serializers.ModelSerializer):
    account = MinimalAccountSerilizer()

    class Meta:
        model = AccountUser
        fields = ["id", "state", "account"]
        read_only_fields = ["account"]


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
