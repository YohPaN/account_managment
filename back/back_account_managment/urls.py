from django.urls import path
from back_account_managment.views import LoginView, UserView, IsLoggedView


urlpatterns = [
    path('login/', LoginView.as_view(), name="login_view"),
    path('user/', UserView.as_view(), name="user_view"),
    path('is_logged/', IsLoggedView.as_view(), name="is_logged_view")
]