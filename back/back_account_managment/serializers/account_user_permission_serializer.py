from back_account_managment.models import AccountUserPermission
from rest_framework import serializers


class AccountUserPermissionsMeta:
    model = AccountUserPermission
    fields = ["permissions"]


class _AccountUserPermissionsSerializer(serializers.Serializer):
    permissions_codename = serializers.CharField(
        source="permissions.codename",
        read_only=True,
    )

    class Meta:
        pass


class AccountUserPermissionsSerializer(_AccountUserPermissionsSerializer):
    class Meta(AccountUserPermissionsMeta):
        pass
