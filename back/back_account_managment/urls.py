from django.urls import path
from back_account_managment import views


urlpatterns = [
    path('login/', views.LoginView.as_view(), name="login_view"),
    path('user/', views.UserView.as_view(), name="user_view"),
    path('is_logged/', views.IsLoggedView.as_view(), name="is_logged_view"),
    path('item/', views.ItemView.as_view(), name="item_view")
]