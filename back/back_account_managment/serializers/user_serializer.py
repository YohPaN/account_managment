from back_account_managment.models import Category
from back_account_managment.serializers.category_serializer import (
    CategorySerializer,
)
from back_account_managment.serializers.profile_serializer import (
    ProfileSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.contenttypes.models import ContentType
from rest_framework import serializers


class UserMeta:
    model = get_user_model()
    fields = [
        "username",
        "email",
        "password",
        "profile",
        "categories",
    ]


class _UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()
    categories = serializers.SerializerMethodField()

    class Meta:
        pass

    def get_categories(self, obj):
        categories = Category.objects.filter(
            object_id=obj.pk,
            content_type=ContentType.objects.get_for_model(get_user_model()),
        )

        return CategorySerializer(categories, many=True).data


class RegisterUserSerializer(_UserSerializer):
    class Meta(UserMeta):
        fields = [
            field
            for field in UserMeta.fields
            if field in ["username", "email", "password"]
        ]


class UserSerializer(_UserSerializer):
    class Meta(UserMeta):
        fields = [
            field
            for field in UserMeta.fields
            if field
            in [
                "username",
                "email",
                "profile",
                "categories",
            ]
        ]


class UsernameUserSerilizer(_UserSerializer):
    class Meta(UserMeta):
        fields = [field for field in UserMeta.fields if field in ["username"]]
