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
from django.contrib.auth.models import Permission
from django.db.models import Exists, OuterRef, Sum
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
        "salary_based_split",
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
        user = self.context["request"].user

        if user == account.user:
            return []

        account_user_qs = AccountUser.objects.filter(
            user=user,
            account=account,
            id=OuterRef("account_user"),
        )

        permissions = Permission.objects.filter(
            Exists(
                AccountUserPermission.objects.filter(
                    permissions=OuterRef("pk"),
                    account_user__in=account_user_qs,
                )
            )
        )

        return [
            permission["codename"]
            for permission in permissions.values("codename")
        ]

    def get_own_contribution(self, account):
        user = self.context["request"].user

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
                "salary_based_split",
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
