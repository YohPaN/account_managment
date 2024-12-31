from unittest.mock import MagicMock, Mock

from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
    Item,
)
from back_account_managment.permissions import (
    IsAccountContributor,
    IsAccountOwner,
    IsOwner,
    LinkItemUserPermission,
    ManageRessourcePermission,
)
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

        isOwner = IsOwner().has_object_permission(
            request=self.request, view=None, obj=obj
        )

        self.assertTrue(isOwner)

    def test_object_have_not_permission(self):
        obj = Mock()
        obj.user = User.objects.get(username="FooBar")

        isOwner = IsOwner().has_object_permission(
            request=self.request, view=None, obj=obj
        )

        self.assertFalse(isOwner)


class IsAccountOwnerPermissionTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.user2 = User.objects.create(
            username="FooBar", email="foo@bar.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)
        self.item = Item.objects.create(
            title="test",
            valuation=21.21,
            user=self.user,
            account=self.account,
        )

        self.account_user = AccountUser.objects.create(
            user=self.user, account=self.account
        )

        self.account_user_permission = AccountUserPermission.objects.create(
            permissions=Permission.objects.first(),
            account_user=self.account_user,
        )

        factory = APIRequestFactory()
        self.request = factory.get("/")

        self.IsAccountOwner = IsAccountOwner()

    def test_object_have_permission_with_item(self):
        self.request.user = self.user

        self.assertTrue(
            self.IsAccountOwner.has_object_permission(
                request=self.request, view=None, instance=self.item
            )
        )

    def test_object_have_not_permission_with_item(self):
        self.request.user = self.user2

        self.assertFalse(
            self.IsAccountOwner.has_object_permission(
                request=self.request, view=None, instance=self.item
            )
        )

    def test_object_have_permission_with_account(self):
        self.request.user = self.user

        self.assertTrue(
            self.IsAccountOwner.has_object_permission(
                request=self.request, view=None, instance=self.account
            )
        )

    def test_object_have_not_permission_with_account(self):
        self.request.user = self.user2

        self.assertFalse(
            self.IsAccountOwner.has_object_permission(
                request=self.request, view=None, instance=self.account
            )
        )


class ManageRessourcePermissionTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.user2 = User.objects.create(username="Jon", email="jo@do.tes")

        self.account = Account.objects.create(
            id=1, name="test", user=self.user
        )

        self.factory = APIRequestFactory()

        self.ManageRessourcePermission = ManageRessourcePermission()

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
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_post_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.post("/")
        request.user = self.user2

        self.assertFalse(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
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
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_put_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.put("/")
        request.user = self.user2

        self.assertFalse(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
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
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_patch_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.patch("/")
        request.user = self.user2

        self.assertFalse(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
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
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_delete_unauthorize(self):
        AccountUser.objects.create(account=self.account, user=self.user)

        request = self.factory.delete("/")
        request.user = self.user2

        self.assertFalse(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_no_method(self):
        request = self.factory.get("/")
        request.user = self.user
        request.method = "OTHER"

        self.assertFalse(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_can_post_item(self):
        permission = Permission.objects.get(codename="add_item")
        item = Item.objects.create(
            title="test",
            valuation=12.56,
            account=self.account,
            user=self.user,
        )
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=permission
        )

        request = self.factory.post("/")
        request.user = self.user

        self.assertTrue(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=item
            )
        )

    def test_can_safe_method(self):
        request = self.factory.get("/")
        request.user = self.user

        self.assertTrue(
            self.ManageRessourcePermission.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )


class IsAccountContributorTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)

        self.factory = APIRequestFactory()

        self.IsAccountContributor = IsAccountContributor()

    def test_is_account_contributor(self):
        request = self.factory.get("/")
        request.user = self.user

        AccountUser.objects.create(
            account=self.account, user=self.user, state="APPROVED"
        )

        self.assertTrue(
            self.IsAccountContributor.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_is_account_contributor_on_item_request(self):
        request = self.factory.get("/")
        request.user = self.user

        item = Item.objects.create(
            title="test",
            valuation=21.21,
            account=self.account,
            user=self.user,
        )

        AccountUser.objects.create(
            account=self.account, user=self.user, state="APPROVED"
        )

        self.assertTrue(
            self.IsAccountContributor.has_object_permission(
                request=request, view=None, instance=item
            )
        )

    def test_is_NOT_account_contributor(self):
        request = self.factory.get("/")
        request.user = self.user

        self.assertFalse(
            self.IsAccountContributor.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )

    def test_is_account_contributor_not_already_approved(self):
        request = self.factory.get("/")
        request.user = self.user

        AccountUser.objects.create(
            account=self.account, user=self.user, state="PENDING"
        )

        self.assertFalse(
            self.IsAccountContributor.has_object_permission(
                request=request, view=None, instance=self.account
            )
        )


class LinkItemUserPermissionTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)

        self.account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )

        self.view = MagicMock()
        self.view.kwargs = {
            "account_id": self.account.pk,
        }

        self.factory = APIRequestFactory()
        self.request = self.factory.post("/")
        self.request.user = self.user

        self.LinkItemUserPermission = LinkItemUserPermission()

    def test_safe_method(self):
        request = self.factory.get("/")
        request.user = self.user

        self.assertTrue(
            self.LinkItemUserPermission.has_permission(
                request=request, view=None
            )
        )

    def test_delete(self):
        request = self.factory.delete("/")
        request.user = self.user

        self.assertTrue(
            self.LinkItemUserPermission.has_permission(
                request=request, view=None
            )
        )

    def test_has_change_item_perm(self):
        AccountUserPermission.objects.create(
            account_user=self.account_user,
            permissions=Permission.objects.get(codename="change_item"),
        )

        self.assertTrue(
            self.LinkItemUserPermission.has_permission(
                request=self.request, view=self.view
            )
        )

    def test_can_link_empty_item(self):
        self.request.data = {}

        AccountUserPermission.objects.create(
            account_user=self.account_user,
            permissions=Permission.objects.get(
                codename="add_item_without_user"
            ),
        )

        self.assertTrue(
            self.LinkItemUserPermission.has_permission(
                request=self.request, view=self.view
            )
        )

    def test_unauthorize_link_empty_item(self):
        self.request.data = {}

        self.assertFalse(
            self.LinkItemUserPermission.has_permission(
                request=self.request, view=self.view
            )
        )

    def test_can_link_user(self):
        user2 = User.objects.create(username="JonDoe2", email="jon2@doe.test")

        self.request.data = {"username": user2.username}

        AccountUserPermission.objects.create(
            account_user=self.account_user,
            permissions=Permission.objects.get(codename="link_user_item"),
        )

        self.assertTrue(
            self.LinkItemUserPermission.has_permission(
                request=self.request, view=self.view
            )
        )

    def test_unauthorize_link_user(self):
        user2 = User.objects.create(username="JonDoe2", email="jon2@doe.test")

        self.request.data = {"username": user2.username}

        self.assertFalse(
            self.LinkItemUserPermission.has_permission(
                request=self.request, view=self.view
            )
        )
