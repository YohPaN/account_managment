from back_account_managment.models import AccountUser
from back_account_managment.serializers.user_serializer import (
    UsernameUserSerilizer,
)
from rest_framework import serializers


class AccountUserMeta:
    model = AccountUser
    fields = ["id", "user", "state", "account"]
    read_only_fields = ["account"]


class _AccountAccountUserSerializer(serializers.ModelSerializer):
    user = UsernameUserSerilizer()

    class Meta:
        pass


class AccountAccountUserSerializer(_AccountAccountUserSerializer):
    class Meta(AccountUserMeta):
        fields = [
            field
            for field in AccountUserMeta.fields
            if field in ["user", "state"]
        ]


class AccountUserSerializer(_AccountAccountUserSerializer):
    class Meta(AccountUserMeta):
        fields = [
            field
            for field in AccountUserMeta.fields
            if field in ["id", "state", "account"]
        ]
