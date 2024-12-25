from back_account_managment.models import Item
from back_account_managment.serializers.user_serializer import (
    UsernameUserSerilizer,
)
from rest_framework import serializers


class ItemMeta:
    model = Item
    fields = ["id", "title", "description", "valuation", "account", "user"]
    read_only_fields = ["account"]


class _ItemSerializer(serializers.ModelSerializer):
    user = UsernameUserSerilizer()

    class Meta:
        pass


class ItemWriteSerializer(_ItemSerializer):
    class Meta(ItemMeta):
        fields = [
            field
            for field in ItemMeta.fields
            if field in ["title", "description", "valuation", "account"]
        ]


class ItemReadSerializer(_ItemSerializer):
    class Meta(ItemMeta):
        fields = [
            field
            for field in ItemMeta.fields
            if field
            in ["id", "title", "description", "valuation", "account", "user"]
        ]
