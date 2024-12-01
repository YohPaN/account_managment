from back_account_managment.models import AccountUser, AccountUserPermission
from django.contrib.auth import get_user_model
from django.db.models import Exists
from rest_framework import permissions

User = get_user_model()


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if getattr(obj, "user", None) is None:
            return True

        return obj.user == request.user


class IsContributor(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if request.method != "GET":
            return False

        contributor_user = User.objects.filter(Exists(obj.contributors()))

        return request.user in contributor_user


class CanCreate(permissions.BasePermission):
    def has_object_permission(self, request, view, account):
        account_user = AccountUser.objects.get(
            user=request.user, account=account
        )

        account_user_permissions = AccountUserPermission.objects.filter(
            account_user=account_user, permissions=25
        )

        if account_user_permissions is not None:
            return True

        return False


class CanUpdate(permissions.BasePermission):
    def has_object_permission(self, request, view, account):
        account_user = AccountUser.objects.get(
            user=request.user, account=account
        )

        account_user_permissions = AccountUserPermission.objects.filter(
            account_user=account_user, permissions=26
        )

        if account_user_permissions is not None:
            return True

        return False


class CanDelete(permissions.BasePermission):
    def has_object_permission(self, request, view, account):
        account_user = AccountUser.objects.get(
            user=request.user, account=account
        )

        account_user_permissions = AccountUserPermission.objects.filter(
            account_user=account_user, permissions=27
        )

        if account_user_permissions is not None:
            return True

        return False
