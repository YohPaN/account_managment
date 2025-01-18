from back_account_managment.models import UserCategory
from back_account_managment.serializers.category_serializer import (
    CategorySerializer,
)
from rest_framework import serializers


class UserCategoryMeta:
    model = UserCategory
    fields = [
        "category",
    ]


class _UserCategorySerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)

    class Meta:
        pass


class UserCategorySerializer(_UserCategorySerializer):
    class Meta(UserCategoryMeta):
        pass
