from back_account_managment.models import Item, Transfert
from back_account_managment.serializers.category_serializer import (
    CategorySerializer,
)
from back_account_managment.serializers.user_serializer import (
    UsernameUserSerilizer,
)
from rest_framework import serializers


class ItemMeta:
    model = Item
    fields = [
        "id",
        "title",
        "description",
        "valuation",
        "account",
        "user",
        "to_account",
        "category",
        "category_id",
    ]
    read_only_fields = ["account"]


class _ItemSerializer(serializers.ModelSerializer):
    user = UsernameUserSerilizer()
    to_account = serializers.SerializerMethodField()
    category = CategorySerializer()

    class Meta:
        pass

    def get_to_account(self, item):
        transfert = Transfert.objects.filter(item=item).first()

        return {
            "id": transfert.to_account.pk if transfert else None,
            "name": transfert.to_account.name if transfert else None,
        }


class ItemWriteSerializer(_ItemSerializer):
    category_id = serializers.IntegerField()

    class Meta(ItemMeta):
        fields = [
            field
            for field in ItemMeta.fields
            if field
            in [
                "title",
                "description",
                "valuation",
                "account",
                "category_id",
            ]
        ]


class ItemReadSerializer(_ItemSerializer):
    class Meta(ItemMeta):
        fields = [
            field
            for field in ItemMeta.fields
            if field
            in [
                "id",
                "title",
                "description",
                "valuation",
                "account",
                "user",
                "to_account",
                "category",
            ]
        ]
