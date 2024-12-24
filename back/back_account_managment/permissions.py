from back_account_managment.models import (
    AccountUser,
    AccountUserPermission,
    Item,
)
from django.contrib.auth import get_user_model
from rest_framework import permissions
from rest_framework.permissions import SAFE_METHODS

User = get_user_model()


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class IsAccountOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, instance):
        if isinstance(instance, Item):
            account = instance.account

        elif isinstance(instance, AccountUserPermission):
            account = instance.account_user.account

        else:
            account = instance

        return account.user == request.user


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

        account_user = AccountUser.objects.filter(
            user=request.user, account=account
        ).first()

        account_user_permissions = AccountUserPermission.objects.filter(
            account_user=account_user, permissions__codename=codename
        ).first()

        if account_user_permissions is not None:
            return True

        return False


class IsAccountContributor(permissions.BasePermission):
    def has_object_permission(self, request, view, instance):
        if isinstance(instance, Item):
            account = instance.account
        else:
            account = instance

        account_user = AccountUser.objects.filter(
            user=request.user, account=account
        ).first()

        if account_user is not None and account_user.state == "APPROVED":
            return True

        return False


class LinkItemUserPermission(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in [*SAFE_METHODS, "DELETE"]:
            return True

        account_user = AccountUser.objects.get(
            user=request.user,
            account_id=view.kwargs.get("account_id"),
        )

        permissions = AccountUserPermission.objects.filter(
            account_user=account_user,
        ).values_list("permissions__codename", flat=True)

        if "change_item" in permissions:
            return True

        username = request.data.get("username", None)

        if username is None:
            return "add_item_without_user" in permissions
        else:
            return "link_user_item" in permissions
