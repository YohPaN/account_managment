from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from rest_framework import permissions
from rest_framework.permissions import SAFE_METHODS

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

        if account_user is None or account_user.state != "APPROVED":
            return False

        account_user_permissions = AccountUserPermission.objects.filter(
            account_user=account_user, permissions=permission
        ).first()

        if account_user_permissions is not None:
            return True

        return False


class ManageAccountUserPermissions(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True

        try:
            account = Account.objects.get(pk=view.kwargs["account_id"])

        except Account.DoesNotExist:
            raise Account.DoesNotExist("Account does not exist")

        if account.user == request.user:
            return True

        return False


class LinkItemUserPermission(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in SAFE_METHODS:
            return True

        user = request.user
        username = request.data.get("username", None)
        account = Account.objects.filter(
            pk=view.kwargs.get("account_id")
        ).first()

        if account is None:
            return False

        if account.user == user or (
            username == user.username and request.method == "POST"
        ):
            return True

        account_user = AccountUser.objects.get(
            user=user,
            account=account,
        )

        link_user_item = AccountUserPermission.objects.filter(
            account_user=account_user,
            permissions=Permission.objects.get(codename="link_user_item"),
        ).first()

        add_item_without_user = AccountUserPermission.objects.filter(
            account_user=account_user,
            permissions=Permission.objects.get(
                codename="add_item_without_user"
            ),
        ).first()

        if username is None:
            return add_item_without_user is not None

        else:
            return link_user_item is not None
