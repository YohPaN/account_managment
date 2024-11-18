from rest_framework import permissions


class IsOwner(permissions.BasePermission):
    def has_permission(self, request, view):
        model_id = view.kwargs.get("pk", None)

        if request.method not in ["GET", "PATCH", "PUT", "DELETE"]:
            return True

        if request.method == "GET" and model_id is None:
            return True

        try:
            model = view.queryset.model

            ressource = model.objects.get(pk=model_id)
        except model.DoesNotExist:
            return False

        return ressource.user == request.user
