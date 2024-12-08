from unittest.mock import Mock

from back_account_managment.permissions import IsOwner
from django.contrib.auth import get_user_model
from django.test import TestCase
from rest_framework.test import APIRequestFactory

User = get_user_model()


class IsOwnerPermissionTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.user2 = User.objects.create(
            username="FooBar", email="foo@bar.test"
        )

        factory = APIRequestFactory()
        self.request = factory.get("/")
        self.request.user = self.user

    def test_object_have_permission(self):
        obj = Mock()
        obj.user = User.objects.get(username="JonDoe")

        isOwner = IsOwner.has_object_permission(
            self=None, request=self.request, view=None, obj=obj
        )

        self.assertTrue(isOwner)

    def test_object_have_not_permission(self):
        obj = Mock()
        obj.user = User.objects.get(username="FooBar")

        isOwner = IsOwner.has_object_permission(
            self=None, request=self.request, view=None, obj=obj
        )

        self.assertFalse(isOwner)


class IsContributorPermissionTest(TestCase):
    def setUp(cls):
        pass


class CanCreatePermissionTest(TestCase):
    def setUp(cls):
        pass


class CanUpdatePermissionTest(TestCase):
    def setUp(cls):
        pass


class CanDeletePermissionTest(TestCase):
    def setUp(cls):
        pass
