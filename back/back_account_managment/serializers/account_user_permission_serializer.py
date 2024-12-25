from back_account_managment.models import AccountUserPermission
from rest_framework import serializers


class AccountUserPermissionsMeta:
    model = AccountUserPermission
    fields = ["permissions"]


class _AccountUserPermissionsSerializer(serializers.Serializer):
    permissions_codename = serializers.SerializerMethodField()

    class Meta:
        pass

    def get_permissions_codename(self, obj):
        return obj.permissions.codename


class AccountUserPermissionsSerializer(_AccountUserPermissionsSerializer):
    class Meta(AccountUserPermissionsMeta):
        pass
