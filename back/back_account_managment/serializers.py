from rest_framework import serializers
from back_account_managment.models import Account, Item, Profile, AccountUser
from django.contrib.auth import get_user_model

User = get_user_model()


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = ["first_name", "last_name", "salary"]


class UserSerializer(serializers.ModelSerializer):
    profile = ProfileSerializer()

    class Meta:
        model = User
        fields = ["username", "email", "password", "profile"]


class UserAccountUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username"]


class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["id", "title", "description", "valuation", "account"]


class AccountUserSerializer(serializers.ModelSerializer):
    user = UserAccountUserSerializer()

    class Meta:
        model = AccountUser
        fields = ["user", "state"]


class AccountSerializer(serializers.ModelSerializer):
    items = ItemSerializer(many=True)
    contributors = AccountUserSerializer(many=True)

    class Meta:
        model = Account
        fields = ["id", "name", "total", "items", "contributors"]


class ManageAccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ["id", "name", "user"]
