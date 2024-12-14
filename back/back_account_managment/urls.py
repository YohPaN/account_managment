from back_account_managment import views
from django.urls import include, path
from rest_framework import routers

router = routers.DefaultRouter()
router.register(r"accounts", views.AccountView)
router.register(r"users", views.UserView)
router.register(
    r"accounts/(?P<account_id>[^/.]+)/items", views.ItemView, basename="items"
)
router.register(
    r"accounts/(?P<account_id>[^/.]+)/(?P<user_username>[^/.]+)/permissions",
    views.AccountUserPermissionView,
    basename="permissions",
)

urlpatterns = [
    path("register/", views.RegisterView.as_view(), name="register"),
    path("", include(router.urls)),
]
