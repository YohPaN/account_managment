from back_account_managment.models import Category
from rest_framework import serializers


class CategoryMeta:
    model = Category
    fields = ["title", "color", "icon", "account", "user"]


class _CategorySerializer(serializers.ModelSerializer):
    class Meta:
        pass


class CategorySerializer(_CategorySerializer):
    class Meta(CategoryMeta):
        pass
