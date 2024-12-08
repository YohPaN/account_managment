from unittest.mock import Mock

from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
)
from back_account_managment.permissions import CRUDAccountPermission, IsOwner
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
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


class CRUDAccountTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.account = Account.objects.create(
            id=1, name="test", user=self.user
        )

        self.factory = APIRequestFactory()

        self.CRUDAccountPermission = CRUDAccountPermission

    def test_can_get(self):
        permission = Permission.objects.get(codename="view_account")
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=permission
        )

        request = self.factory.get("/")
        request.user = self.user

        self.assertTrue(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_get_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.get("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_get_for_not_contributor_user(self):
        request = self.factory.get("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_can_post(self):
        permission = Permission.objects.get(codename="add_account")
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=permission
        )

        request = self.factory.post("/")
        request.user = self.user

        self.assertTrue(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_post_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.post("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_post_for_not_contributor_user(self):
        request = self.factory.post("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_can_put(self):
        permission = Permission.objects.get(codename="change_account")
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=permission
        )

        request = self.factory.put("/")
        request.user = self.user

        self.assertTrue(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_put_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.put("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_put_for_not_contributor_user(self):
        request = self.factory.put("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_can_patch(self):
        permission = Permission.objects.get(codename="change_account")
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=permission
        )

        request = self.factory.patch("/")
        request.user = self.user

        self.assertTrue(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_patch_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.patch("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_patch_for_not_contributor_user(self):
        request = self.factory.patch("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_can_delete(self):
        permission = Permission.objects.get(codename="delete_account")
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=permission
        )

        request = self.factory.delete("/")
        request.user = self.user

        self.assertTrue(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_delete_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.delete("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_delete_for_not_contributor_user(self):
        request = self.factory.delete("/")
        request.user = self.user

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )

    def test_no_method(self):
        request = self.factory.get("/")
        request.user = self.user
        request.method = "OTHER"

        self.assertFalse(
            self.CRUDAccountPermission.has_object_permission(
                self=None, request=request, view=None, account=self.account
            )
        )
