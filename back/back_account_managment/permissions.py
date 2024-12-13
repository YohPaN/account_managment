from back_account_managment.models import (
    AccountUser,
    AccountUserPermission,
    Item,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from rest_framework import permissions

User = get_user_model()


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class CRUDPermission(permissions.BasePermission):
    def has_object_permission(self, request, view, instance):
        method = request.method
        ressource_name = instance.__class__.__name__.lower()

        if isinstance(instance, Item):
            account = instance.account
        else:
            account = instance

        match method:
            case "GET":
                codename = f"view_{ressource_name}"

            case "POST":
                codename = f"add_{ressource_name}"

            case "PUT" | "PATCH":
                codename = f"change_{ressource_name}"

            case "DELETE":
                codename = f"delete_{ressource_name}"

            case _:
                return False

        if account.user == request.user:
            return True

        permission = Permission.objects.get(codename=codename)

        account_user = AccountUser.objects.filter(
            user=request.user, account=account
        ).first()

        if account_user is None:
            return False

        account_user_permissions = AccountUserPermission.objects.filter(
            account_user=account_user, permissions=permission
        ).first()

        if account_user_permissions is not None:
            return True

        return False
