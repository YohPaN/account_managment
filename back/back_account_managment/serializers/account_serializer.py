from decimal import Decimal

from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
)
from back_account_managment.serializers.account_user_permission_serializer import (  # noqa
    AccountUserPermissionsSerializer,
)
from back_account_managment.serializers.account_user_serializer import (
    AccountAccountUserSerializer,
)
from back_account_managment.serializers.item_serializer import (
    ItemReadSerializer,
)
from back_account_managment.serializers.user_serializer import (
    UsernameUserSerilizer,
)
from django.db.models import Sum
from rest_framework import serializers


class AccountMeta:
    model = Account
    fields = [
        "contributors",
        "id",
        "is_main",
        "items",
        "name",
        "need_to_add",
        "own_contribution",
        "permissions",
        "total",
        "user",
    ]


class _AccountSerializer(serializers.ModelSerializer):
    items = ItemReadSerializer(many=True)
    contributors = AccountAccountUserSerializer(many=True)

    permissions = serializers.SerializerMethodField()

    own_contribution = serializers.SerializerMethodField()
    need_to_add = serializers.SerializerMethodField()

    class Meta:
        pass

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


class AccountListSerializer(_AccountSerializer):
    user = UsernameUserSerilizer()

    class Meta(AccountMeta):
        fields = [
            field
            for field in AccountMeta.fields
            if field
            in [
                "contributors",
                "id",
                "is_main",
                "items",
                "name",
                "permissions",
                "total",
                "user",
            ]
        ]


class AccountSerializer(_AccountSerializer):
    user = UsernameUserSerilizer()

    class Meta(AccountMeta):
        fields = [
            field
            for field in AccountMeta.fields
            if field
            in [
                "contributors",
                "id",
                "is_main",
                "items",
                "name",
                "need_to_add",
                "own_contribution",
                "permissions",
                "total",
                "user",
            ]
        ]


class MinimalAccountSerilizer(_AccountSerializer):
    class Meta(AccountMeta):
        fields = [
            field for field in AccountMeta.fields if field in ["name", "user"]
        ]
