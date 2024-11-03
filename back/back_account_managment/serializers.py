from django.contrib.auth.models import User
from rest_framework import serializers
from back_account_managment.models import Account, Item

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["first_name", "last_name", "username", "email"]


class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = ["id", "name", "total"]

class ItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = Item
        fields = ["title", "description", "valuation"]