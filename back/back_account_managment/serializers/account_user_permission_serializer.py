from back_account_managment.models import AccountUser
from rest_framework import serializers


class AccountUserPermissionsMeta:
    model = AccountUser
    fields = ["permissions"]


class _AccountUserPermissionsSerializer(serializers.Serializer):

    class Meta:
        pass


class AccountUserPermissionsSerializer(_AccountUserPermissionsSerializer):
    class Meta(AccountUserPermissionsMeta):
        pass
