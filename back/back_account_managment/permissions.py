from back_account_managment.models import Account, AccountUser, Item
from django.contrib.auth import get_user_model
from rest_framework import permissions
from rest_framework.permissions import SAFE_METHODS

User = get_user_model()


def determine_account(instance):
    if isinstance(instance, Item):
        return instance.account

    else:
        return instance


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class IsAccountOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, instance):
        account = determine_account(instance)

        return account.user == request.user


class ManageRessourcePermission(permissions.BasePermission):
    def has_object_permission(self, request, view, instance):
        method = request.method

        if request.method in SAFE_METHODS:
            return True

        ressource_name = instance.__class__.__name__.lower()

        account = determine_account(instance)

        match method:
            case "POST":
                codename = f"add_{ressource_name}"

            case "PUT" | "PATCH":
                codename = f"change_{ressource_name}"

            case "DELETE":
                codename = f"delete_{ressource_name}"

            case _:
                return False

        try:
            account_user = AccountUser.objects.get(
                user=request.user, account=account
            )
        except AccountUser.DoesNotExist:
            return False

        if account_user.permissions.filter(codename=codename).count() > 0:
            return True

        return False


class IsAccountContributor(permissions.BasePermission):
    def has_object_permission(self, request, view, instance):
        account = determine_account(instance)

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

        try:
            account_user = AccountUser.objects.get(
                user=request.user,
                account_id=view.kwargs.get("account_id"),
            )
        except AccountUser.DoesNotExist:
            return False

        permissions = account_user.permissions.values_list(
            "codename", flat=True
        )

        if "change_item" in permissions:
            return True

        username = request.data.get("username", None)

        if username is None:
            return "add_item_without_user" in permissions
        else:
            return "link_user_item" in permissions


class TransfertToAccountPermission(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in [*SAFE_METHODS, "DELETE"]:
            return True

        to_account = request.data.get("to_account", None)

        if (
            to_account is None
            or Account.objects.get(pk=to_account).user == request.user
        ):
            return True

        account_user = AccountUser.objects.get(
            user=request.user,
            account_id=request.data.get("to_account"),
        )

        permissions = account_user.permissions.values_list(
            "permissions__codename", flat=True
        )

        return "transfert_item" in permissions
