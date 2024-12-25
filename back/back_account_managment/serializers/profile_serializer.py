from back_account_managment.models import Profile
from rest_framework import serializers


class ProfileMeta:
    model = Profile
    fields = ["user", "first_name", "last_name", "salary"]


class _ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        pass


class ProfileSerializer(_ProfileSerializer):
    class Meta(ProfileMeta):
        pass
