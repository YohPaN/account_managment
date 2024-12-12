from back_account_managment.models import AccountUser, AccountUserPermission
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from rest_framework import permissions

User = get_user_model()


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        # if getattr(obj, "user", None) is None:
        #     return True

        return obj.user == request.user


class CRUDAccountPermission(permissions.BasePermission):
    def has_object_permission(self, request, view, account):
        method = request.method

        match method:
            case "GET":
                codename = "view_account"

            case "POST":
                codename = "add_account"

            case "PUT" | "PATCH":
                codename = "change_account"

            case "DELETE":
                codename = "delete_account"

            case _:
                return False

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
