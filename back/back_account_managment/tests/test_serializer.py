from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
)
from back_account_managment.serializers.account_serializer import (
    AccountSerializer,
)
from back_account_managment.serializers.account_user_permission_serializer import (  # noqa
    AccountUserPermissionsSerializer,
)
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.test import TestCase
from rest_framework.test import APIRequestFactory

User = get_user_model()


class AccountSerializerTest(TestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.user = User.objects.create(
            username="test", email="test@test.test"
        )

        self.request = self.factory.get("/")

        self.account = Account.objects.create(name="test", user=self.user)

        self.account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )

        self.permission = Permission.objects.get(codename="view_account")

        self.account_user_permission = AccountUserPermission.objects.create(
            account_user=self.account_user, permissions=self.permission
        )

    def test_get_permissions_for_account_owner(self):
        self.request.user = self.user

        serializer = AccountSerializer(context={"request": self.request})

        permissions = serializer.get_permissions(self.account)

        self.assertEqual(
            permissions,
            [
                "owner",
            ],
        )

    def test_get_permissions(self):
        user2 = User.objects.create(username="user2", email="user@user2.test")
        self.request.user = user2

        account_user = AccountUser.objects.create(
            account=self.account, user=user2
        )
        AccountUserPermission.objects.create(
            account_user=account_user, permissions=self.permission
        )

        serializer = AccountSerializer(context={"request": self.request})

        permissions = serializer.get_permissions(self.account)

        self.assertEqual(
            permissions,
            [
                "view_account",
            ],
        )

    def test_no_context(self):
        serializer = AccountSerializer()

        with self.assertRaises(KeyError):
            serializer.get_permissions(self.account)

    def test_user_is_not_a_contributor(self):
        new_user = User.objects.create(
            username="newUser", email="new@user.test"
        )

        self.request.user = new_user

        with self.assertRaises(AccountUser.DoesNotExist):
            serializer = AccountSerializer(context={"request": self.request})
            serializer.get_permissions(self.account)


class AccountUserPermissionSerializerTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="test", email="test@test.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)

        self.account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )

        self.content_type = ContentType.objects.create(
            app_label="test", model="model"
        )

        self.permission = Permission.objects.create(
            codename="test_code",
            name="Test perm",
            content_type=self.content_type,
        )

        self.account_user_permission = AccountUserPermission.objects.create(
            account_user=self.account_user, permissions=self.permission
        )

    def test_get_permission_code(self):
        serializer = AccountUserPermissionsSerializer(
            self.account_user_permission
        )

        self.assertEqual(
            serializer.data, {"permissions_codename": "test_code"}
        )
