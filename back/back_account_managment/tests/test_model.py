from back_account_managment.models import (
    Account,
    AccountUser,
    Category,
    Item,
    Transfert,
)
from django.contrib.auth import get_user_model
from django.contrib.contenttypes.models import ContentType
from django.db.utils import IntegrityError
from django.test import TestCase

User = get_user_model()


class AccountManagerTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="jonDoe",
            email="jon@doe.test",
        )
        self.user2 = User.objects.create(
            username="testeur",
            email="test@eur.test",
        )

        self.main_account = Account.objects.create(
            user=self.user, name="first name", is_main=True
        )
        self.account = Account.objects.create(
            user=self.user, name="first name"
        )
        self.account2 = Account.objects.create(
            user=self.user2, name="first name"
        )

        AccountUser.objects.create(
            account=self.account2, user=self.user, state="APPROVED"
        )

    def test_get_own_accounts_and_contributions(self):
        queryset = Account.objects.all()

        own_and_contrib_accounts = (
            Account.objects.get_own_accounts_and_contributions(
                queryset=queryset, user=self.user
            )
        )

        self.assertEqual(len(own_and_contrib_accounts), 3)


class AccountModelTest(TestCase):
    fixtures = ["default_categories"]

    def setUp(self):
        self.user = User.objects.create(
            username="jonDoe",
            email="jon@doe.test",
        )

        self.account = Account.objects.create(
            user=self.user, name="first name"
        )
        self.account2 = Account.objects.create(
            user=self.user, name="first name"
        )
        self.account3 = Account.objects.create(
            user=self.user, name="first name"
        )

        self.default_category = Category.objects.get(pk=1)
        self.category = Category.objects.create(
            title="test_category",
            icon={},
            content_type=ContentType.objects.get_for_model(User),
            object_id=self.user.pk,
        )
        self.category_under_account2 = Category.objects.create(
            title="test_category",
            icon={},
            content_type=ContentType.objects.get_for_model(Account),
            object_id=self.account2.pk,
        )

    def test_manage_category_add(self):
        self.account.manage_category(self.category.pk, link=True)

        self.assertEqual(len(self.account.categories.all()), 1)

    def test_manage_category_remove(self):
        self.account.categories.add(self.category)

        self.assertEqual(len(self.account.categories.all()), 1)

        response = self.account.manage_category(self.category.pk, link=False)

        self.assertTrue(response)
        self.assertEqual(len(self.account.categories.all()), 0)

    def test_manage_category_with_non_existing_category(self):
        category_with_1000_pk = Category.objects.filter(pk=1000)

        self.assertFalse(category_with_1000_pk.exists())

        response = self.account.manage_category(1000, link=True)

        self.assertIn("error", response)
        self.assertEqual(len(self.account.categories.all()), 0)

    def test_manage_category_with_category_not_under_account(self):
        self.account2.categories.add(self.category_under_account2)

        response = self.account3.manage_category(
            self.category_under_account2.pk, link=True
        )

        self.assertIn("error", response)
        self.assertEqual(len(self.account.categories.all()), 0)

    def test_manage_category_with_default_category_not_under_account(self):
        response = self.account.manage_category(
            self.default_category.pk, link=True
        )

        self.assertTrue(response)
        self.assertEqual(len(self.account.categories.all()), 1)

    def test_manage_category_with_user_category_not_under_account(self):
        response = self.account.manage_category(self.category.pk, link=True)

        self.assertTrue(response)
        self.assertEqual(len(self.account.categories.all()), 1)

    def test_manage_category_with_category_already_under_account(self):
        self.account.categories.add(self.category)

        response = self.account.manage_category(self.category.pk, link=True)

        self.assertTrue(response)
        self.assertEqual(len(self.account.categories.all()), 1)


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


class ItemModelTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="JonDoe", email="jon@doe.test"
        )
        self.account = Account.objects.create(name="test", user=self.user)
        self.account2 = Account.objects.create(name="test", user=self.user)

        self.item = Item.objects.create(
            title="test",
            valuation=21.21,
            user=self.user,
            account=self.account,
        )

    def test_manage_transfer_create(self):
        self.item.manage_transfer(self.account.pk)

        self.assertEqual(Transfert.objects.filter(item=self.item).count(), 1)

    def test_manage_transfer_update(self):
        Transfert.objects.create(item=self.item, to_account=self.account)

        self.assertEqual(
            Transfert.objects.get(item=self.item).to_account, self.account
        )

        self.item.manage_transfer(self.account2.pk)

        self.assertEqual(
            Transfert.objects.get(item=self.item).to_account, self.account2
        )

    def test_manage_transfer_without_to_account(self):
        self.item.manage_transfer()

    def test_manage_transfer_without_to_account_on_transfert_existing(self):
        Transfert.objects.create(item=self.item, to_account=self.account)

        self.assertEqual(Transfert.objects.filter(item=self.item).count(), 1)

        self.item.manage_transfer()

        self.assertEqual(Transfert.objects.filter(item=self.item).count(), 0)
