from decimal import Decimal

from back_account_managment.models import Account, AccountUser, Item, Transfert
from django.contrib.auth import get_user_model
from django.db.utils import IntegrityError
from django.test import TestCase

User = get_user_model()


class AccountModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)
        self.account2 = Account.objects.create(name="test", user=self.user)

        for _ in range(3):
            Item.objects.create(
                title="test",
                valuation=12,
                account=self.account,
                user=self.user,
            )

        Item.objects.create(
            title="test",
            valuation=-23,
            account=self.account,
            user=self.user,
        )

        self.item_on_account2 = Item.objects.create(
            title="test",
            valuation=-59,
            account=self.account2,
            user=self.user,
        )

        self.item2_on_account2 = Item.objects.create(
            title="test",
            valuation=-14,
            account=self.account2,
            user=self.user,
        )

    def test_total_property(self):
        self.assertEqual(self.account.total["total_sum"], 13)

    def test_total_property_with_transfert(self):
        Transfert.objects.create(
            item=self.item_on_account2, to_account=self.account
        ),
        Transfert.objects.create(
            item=self.item2_on_account2, to_account=self.account
        ),

        self.assertEqual(self.account.total["total_sum"], Decimal("86"))


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
