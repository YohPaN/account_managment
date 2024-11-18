from back_account_managment.models import Account
from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS:
            return True

        account_id = view.kwargs.get("pk")
        if not account_id:
            return False

        try:
            account = Account.objects.get(pk=account_id)
        except Account.DoesNotExist:
            return False

        return account.user == request.user
