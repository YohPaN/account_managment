from back_account_managment.models import (
    Account,
    AccountUser,
    AccountUserPermission,
)
from back_account_managment.serializers import AccountUserPermissionsSerializer
from django.contrib.auth import get_user_model
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.test import TestCase

User = get_user_model()


class UserSerializerTest(TestCase):
    """Nothing to test"""


class ProfileSerializerTest(TestCase):
    """Nothing to test"""


class UserAccountUserSerializerTest(TestCase):
    """Nothing to test"""


class AccountSerializerTest(TestCase):
    def setUp(cls):
        pass


class ItemSerializerTest(TestCase):
    """Nothing to test"""


class AccountUserSerializerTest(TestCase):
    """Nothing to test"""


class ManageAccountSerializerTest(TestCase):
    """Nothing to test"""


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
