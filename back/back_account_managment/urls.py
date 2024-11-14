from django.urls import path, include
from back_account_managment import views
from rest_framework import routers

router = routers.DefaultRouter()
router.register(r'items', views.ItemView)
router.register(r'accounts', views.AccountView)
router.register(r'profile', views.ProfileView)
router.register(r'users', views.UserView)

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name="login"),
    path('is_logged/', views.IsLoggedView.as_view(), name="is_logged_view"),
    path('', include(router.urls)),
]
