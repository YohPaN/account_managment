from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        if getattr(obj, "user", None) is None:
            return True

        return obj.user == request.user
