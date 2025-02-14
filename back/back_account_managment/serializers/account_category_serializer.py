from back_account_managment.models import Account
from rest_framework import serializers


class AccountCategoryMeta:
    model = Account
    fields = ["category", "account"]


class _AccountCategorySerializer(serializers.ModelSerializer):
    class Meta:
        pass


class AccountCategorySerializer(_AccountCategorySerializer):
    class Meta(AccountCategoryMeta):
        fields = [
            field
            for field in AccountCategoryMeta.fields
            if field in ["category", "account"]
        ]
