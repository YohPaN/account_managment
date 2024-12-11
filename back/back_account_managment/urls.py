from back_account_managment import views
from django.urls import include, path
from rest_framework import routers

router = routers.DefaultRouter()
router.register(r"accounts", views.AccountView)
router.register(r"users", views.UserView)

urlpatterns = [
    path("register/", views.RegisterView.as_view(), name="register"),
    path("", include(router.urls)),
]
