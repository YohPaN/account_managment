from back_account_managment.views import (
    AccountCategoryView,
    AccountUserPermissionView,
    AccountUserView,
    AccountView,
    CategoryView,
    ItemView,
    RegisterView,
    UserView,
)
from django.urls import include, path
from rest_framework import routers

router = routers.DefaultRouter()
router.register(r"accounts", AccountView)
router.register(r"users", UserView)
router.register(r"categories", CategoryView)
router.register(
    r"account-categories", AccountCategoryView, basename="account-categories"
)
router.register(r"account_user", AccountUserView)
router.register(
    r"accounts/(?P<account_id>[^/.]+)/items", ItemView, basename="items"
)
router.register(
    r"accounts/(?P<account_id>[^/.]+)/(?P<user_username>[^/.]+)/permissions",
    AccountUserPermissionView,
    basename="permissions",
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("", include(router.urls)),
]
