from decimal import Decimal

from back_account_managment.models import (
    Account,
    AccountCategory,
    AccountUser,
    AccountUserPermission,
    Category,
    Item,
    Profile,
    Transfert,
)
from back_account_managment.serializers.account_user_permission_serializer import (  # noqa
    AccountUserPermissionsSerializer,
)
from back_account_managment.serializers.account_user_serializer import (
    AccountAccountUserSerializer,
)
from back_account_managment.serializers.category_serializer import (
    CategorySerializer,
)
from back_account_managment.serializers.item_serializer import (
    ItemReadSerializer,
)
from back_account_managment.serializers.user_serializer import (
    UsernameUserSerilizer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.db.models import Case, Exists, F, OuterRef, Q, Sum, Value, When
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
        "transfert_items",
        "categories",
    ]


class _AccountSerializer(serializers.ModelSerializer):
    items = ItemReadSerializer(many=True)
    transfert_items = serializers.SerializerMethodField()
    contributors = AccountAccountUserSerializer(many=True)

    permissions = serializers.SerializerMethodField()

    own_contribution = serializers.SerializerMethodField()
    need_to_add = serializers.SerializerMethodField()

    categories = serializers.SerializerMethodField()

    class Meta:
        pass

    def get_transfert_items(self, account):
        transferts = Transfert.objects.filter(
            to_account=account, item=OuterRef("pk")
        )
        items = Item.objects.filter(Exists(transferts))

        return ItemReadSerializer(items, many=True).data

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

        transfert_item = Transfert.objects.filter(
            to_account=account, item=OuterRef("pk")
        )

        total = Item.objects.annotate(
            calc_valuation=Case(
                When(Exists(transfert_item), then=F("valuation") * Value(-1)),
                default=F("valuation"),
            )
        ).filter(
            Q(account=account) | Exists(transfert_item),
            user=user,
            calc_valuation__gt=0,
        )

        if total.count() > 0:
            return total.aggregate(total=(Sum("calc_valuation")))

        return {"total": Decimal(0.00)}

    def get_need_to_add(self, account):
        user = self.context["request"].user

        transfert_item = Transfert.objects.filter(
            to_account=account, item=OuterRef("pk")
        )

        total = Item.objects.annotate(
            calc_valuation=Case(
                When(Exists(transfert_item), then=F("valuation") * Value(-1)),
                default=F("valuation"),
            )
        ).filter(
            Q(account=account) | Exists(transfert_item),
            calc_valuation__lt=0,
        )

        if total.count() > 0:
            total = total.aggregate(total=Sum("calc_valuation"))

            if account.salary_based_split is False:
                user_proportion = 1 / (
                    AccountUser.objects.filter(
                        account=account, state="APPROVED"
                    ).count()
                    + 1
                )
            else:
                account_user_user = get_user_model().objects.filter(
                    accountuser__in=AccountUser.objects.filter(
                        account=account, state="APPROVED"
                    )
                )

                if len(account_user_user) > 0:
                    profiles = Profile.objects.filter(
                        user__in=account_user_user
                    )

                    total_salary = profiles.aggregate(
                        total_salary=Sum("salary")
                    )

                    user_salary = Profile.objects.get(user=user).salary

                    admin_salary = Decimal(account.user.profile.salary)

                    user_proportion = user_salary / (
                        total_salary["total_salary"] + admin_salary
                    )

                else:
                    user_proportion = 1

            user_part = round(total["total"] * Decimal(user_proportion), 2)

            return {
                "total": user_part
                + self.get_own_contribution(account=account)["total"]
            }

        return {"total": Decimal(0.00)}

    def get_categories(self, obj):
        categories = Category.objects.filter(
            Exists(
                AccountCategory.objects.filter(
                    account=obj, category=OuterRef("pk")
                )
            )
        )

        return CategorySerializer(categories, many=True).data


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
                "categories",
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
                "transfert_items",
                "user",
                "categories",
            ]
        ]


class MinimalAccountSerilizer(_AccountSerializer):
    class Meta(AccountMeta):
        fields = [
            field for field in AccountMeta.fields if field in ["name", "user"]
        ]
