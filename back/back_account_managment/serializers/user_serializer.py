from back_account_managment.serializers.profile_serializer import (
    ProfileSerializer,
)
from django.contrib.auth import get_user_model
from rest_framework import serializers


class UserMeta:
    model = get_user_model()
    fields = ["username", "email", "password", "profile"]


class _UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        pass


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
            if field in ["username", "email", "profile"]
        ]
        fields = ["username", "email", "profile"]


class UsernameUserSerilizer(_UserSerializer):
    class Meta(UserMeta):
        fields = [field for field in UserMeta.fields if field in ["username"]]
