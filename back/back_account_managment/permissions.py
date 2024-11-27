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
