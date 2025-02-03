from back_account_managment.models import Category
from rest_framework import serializers


class CategoryMeta:
    model = Category
    fields = [
        "id",
        "title",
        "color",
        "icon",
        "content_type",
        "object_id",
    ]


class _CategorySerializer(serializers.ModelSerializer):
    class Meta:
        pass


class CategorySerializer(_CategorySerializer):
    class Meta(CategoryMeta):
        pass


class CategoryWriteSerializer(_CategorySerializer):
    class Meta(CategoryMeta):
        fields = [
            field
            for field in CategoryMeta.fields
            if field
            in [
                "id",
                "title",
                "color",
                "icon",
            ]
        ]
