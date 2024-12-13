from back_account_managment.models import Account, AccountUser, Item
from django.contrib.auth import get_user_model
from django.db.utils import IntegrityError
from django.test import TestCase

User = get_user_model()


class UserModelTest(TestCase):
    """Nothing to test"""


class ProfileModelTest(TestCase):
    """Nothing to test"""


class AccountModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )
        self.account = Account.objects.create(
            id=1, name="test", user=self.user
        )

    def test_total_property(self):
        for i in range(3):
            Item.objects.create(
                title="test",
                description="test",
                valuation=12,
                account=self.account,
            )

        account = Account.objects.get(pk=1)
        self.assertEqual(account.total["total_sum"], 36)


class ItemModelTest(TestCase):
    """Nothing to test"""


class AccountUserModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )
        self.account = Account.objects.create(
            id=1, name="test", user=self.user
        )

    def test_create_account_user_with_bad_state(self):
        with self.assertRaises(IntegrityError):
            AccountUser.objects.create(
                state="BAD_STATE", user=self.user, account=self.account
            )

    def test_create_account_user_with_all_state_possible(self):
        AccountUser.objects.create(
            state="PENDING", user=self.user, account=self.account
        )
        AccountUser.objects.create(
            state="APPROVED", user=self.user, account=self.account
        )
        AccountUser.objects.create(
            state="DISAPPROVED", user=self.user, account=self.account
        )

        self.assertEqual(len(AccountUser.objects.all()), 3)


class AccountUserPermissionModelTest(TestCase):
    """Nothing to test"""
