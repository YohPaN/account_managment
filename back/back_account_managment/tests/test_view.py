import json
from decimal import Decimal

from back_account_managment.models import (
    AccountCategory,
    AccountUserPermission,
    Category,
    Profile,
    Transfert,
)
from back_account_managment.views import Account, AccountUser, Item
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password
from django.contrib.auth.models import Permission
from django.contrib.contenttypes.models import ContentType
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient

User = get_user_model()


class UserViewTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="jonDoe",
            email="jon@doe.test",
        )
        self.user2 = User.objects.create(
            username="testeur",
            email="jon@doe.testeur",
        )
        self.user.set_password("password"),

        self.profile = Profile.objects.create(
            first_name="test",
            last_name="test",
            salary=20.12,
            user=self.user,
        )

        self.category_under_user = Category.objects.create(
            title="test_category",
            content_type=ContentType.objects.get_for_model(User),
            object_id=self.user.pk,
        )

        self.other_category = Category.objects.create(
            title="test",
        )

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_get_current_user(self):
        response = self.c.get("/api/users/me/")
        self.assertTrue(status.is_success(response.status_code))

        self.assertIn("username", response.data)
        self.assertIn("email", response.data)
        self.assertIn("profile", response.data)
        self.assertIn("categories", response.data)
        self.assertEqual(response.data["username"], "jonDoe")
        self.assertEqual(response.data["email"], "jon@doe.test")
        self.assertEqual(response.data["profile"]["first_name"], "test")
        self.assertEqual(response.data["profile"]["last_name"], "test")
        self.assertEqual(response.data["profile"]["salary"], "20.12")
        self.assertEqual(len(response.data["categories"]), 1)
        self.assertEqual(
            response.data["categories"][0]["title"], "test_category"
        )

    def test_update_profile(self):
        response = self.c.patch(
            "/api/users/me/update/",
            {
                "username": "JonTheRipper",
                "email": "jon@the.ripper",
                "first_name": "first_name",
                "last_name": "last_name",
                "salary": 50.04,
            },
            format="json",
        )

        self.profile.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.user.username, "JonTheRipper")
        self.assertEqual(self.user.email, "jon@the.ripper")
        self.assertEqual(self.profile.first_name, "first_name")
        self.assertEqual(self.profile.last_name, "last_name")
        self.assertEqual(self.profile.salary, Decimal("50.04"))
        self.assertIn("username", response.data)
        self.assertIn("email", response.data)

    def test_update_profile_with_bad_data_for_user(self):
        response = self.c.patch(
            "/api/users/me/update/",
            {
                "username": "@&#aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",  # noqa
                "email": "jon@the.ripper",
                "first_name": "first_name",
                "last_name": "last_name",
                "salary": 50.04,
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 400)

    def test_update_profile_with_bad_data_for_profile(self):
        response = self.c.patch(
            "/api/users/me/update/",
            {
                "username": "JonTheRipper",
                "email": "jon@the.ripper",
                "first_name": "first_name",
                "last_name": "last_name",
                "salary": "50.04@",
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 400)

    def test_update_profile_with_unexisting_profile(self):
        self.c.force_authenticate(user=self.user2)

        response = self.c.patch(
            "/api/users/me/update/",
            {
                "username": "JonTheRipper",
                "email": "jon@the.ripper",
                "first_name": "first_name",
                "last_name": "last_name",
                "salary": 50.04,
            },
            format="json",
        )

        self.assertTrue(status.is_client_error(response.status_code))
        self.assertEqual(response.status_code, 404)

    def test_update_password(self):
        self.assertTrue(check_password("password", self.user.password))

        response = self.c.patch(
            "/api/users/password/",
            {
                "old_password": "password",
                "new_password": "newPassword",
            },
            format="json",
        )
        self.assertTrue(status.is_success(response.status_code))
        self.assertTrue(check_password("newPassword", self.user.password))

    def test_update_password_with_bad_password(self):
        self.assertFalse(check_password("bad password", self.user.password))

        response = self.c.patch(
            "/api/users/password/",
            {
                "old_password": "bad password",
                "new_password": "newPassword",
            },
            format="json",
        )
        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 401)
        self.assertTrue(check_password("password", self.user.password))


class RegisterViewTest(TestCase):
    def setUp(self):
        self.c = APIClient()

    def test_register(self):

        response = self.c.post(
            "/api/register/",
            {
                "username": "JonTheRipper",
                "email": "john@the.ripper",
                "password": "password",
                "first_name": "Jon",
                "last_name": "Doe",
                "salary": 1256.54,
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))

        user = User.objects.get(username="JonTheRipper")
        self.assertIsNotNone(user)
        self.assertTrue(check_password("password", user.password))

        self.assertIsNotNone(Profile.objects.get(first_name="Jon"))
        self.assertEqual(len(Account.objects.all()), 1)
        self.assertIsNotNone(Account.objects.get(user=user))

    def test_error_when_password_is_none(self):
        self.assertEqual(len(User.objects.all()), 0)

        response = self.c.post(
            "/api/register/",
            {
                "username": "JonTheRipper",
                "email": "john@the.ripper",
                "first_name": "Jon",
                "last_name": "Doe",
                "salary": 1256.54,
            },
            format="json",
        )

        self.assertTrue(status.is_client_error(response.status_code))
        self.assertEqual(len(User.objects.all()), 0)

    def test_error_when_cant_create_user(self):
        self.assertEqual(len(User.objects.all()), 0)

        response = self.c.post(
            "/api/register/",
            {
                "username": "JonTheRipper",
                "password": "password",
                "first_name": "Jon",
                "last_name": "Doe",
                "salary": 1256.54,
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(len(User.objects.all()), 0)

    def test_error_when_cant_create_profile(self):
        self.assertEqual(len(User.objects.all()), 0)

        response = self.c.post(
            "/api/register/",
            {
                "username": "JonTheRipper",
                "email": "john@the.ripper",
                "password": "password",
                "last_name": "Doe",
                "salary": 1256.54,
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 400)
        self.assertEqual(len(User.objects.all()), 0)


class AccountViewTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="jonDoe",
            email="jon@doe.test",
        )

        self.user2 = User.objects.create(
            username="testeur",
            email="test@eur.test",
        )
        Profile.objects.create(
            user=self.user2,
            first_name="test",
            last_name="test",
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

        self.default_category = Category.objects.create(
            title="default_category",
        )

        self.category_for_account = Category.objects.create(
            title="category_for_account",
            content_type=ContentType.objects.get_for_model(Account),
            object_id=self.account,
        )

        self.category_for_account2 = Category.objects.create(
            title="category_for_account2",
            content_type=ContentType.objects.get_for_model(Account),
            object_id=self.account2,
        )

        self.category_for_user = Category.objects.create(
            title="category_for_user",
            content_type=ContentType.objects.get_for_model(User),
            object_id=self.user.pk,
        )

        self.account_category = AccountCategory.objects.create(
            account=self.account,
            category=self.category_for_account,
        )

        self.account2_category = AccountCategory.objects.create(
            account=self.account2,
            category=self.category_for_account2,
        )

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_list(self):
        contributor_account = Account.objects.create(
            name="test", user=self.user2
        )
        AccountUser.objects.create(account=contributor_account, user=self.user)

        account_approved = Account.objects.create(name="test", user=self.user2)
        AccountUser.objects.create(
            account=account_approved, user=self.user, state="APPROVED"
        )
        category_for_account = Category.objects.create(
            title="locale_category",
            content_type=ContentType.objects.get_for_model(Account),
            object_id=account_approved,
        )
        AccountCategory.objects.create(
            account=account_approved,
            category=category_for_account,
        )

        response = self.c.get("/api/accounts/")

        self.assertTrue(status.is_success(response.status_code))
        self.assertIn("own", response.data)
        self.assertIn("contributor_account", response.data)
        self.assertIn("categories", response.data["own"][0])
        self.assertIn("categories", response.data["contributor_account"][0])

        self_account = [
            account
            for account in response.data["own"]
            if account["id"] == self.account.pk
        ]

        self.assertTrue(
            any(
                category["title"] == self.category_for_account.title
                for category in self_account[0]["categories"]
            )
        )

        self.assertTrue(
            any(
                category["title"] == category_for_account.title
                for category in response.data["contributor_account"][0][
                    "categories"
                ]
            )
        )
        self.assertEqual(len(response.data["own"]), 2)
        self.assertEqual(len(response.data["contributor_account"]), 1)
        self.assertEqual(len(self_account[0]["categories"]), 1)
        self.assertEqual(
            len(response.data["contributor_account"][0]["categories"]), 1
        )

    def test_get_current_user_account(self):
        response = self.c.get("/api/accounts/me/")
        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(response.data["id"], self.main_account.pk)

    def test_no_account_get_current_user_account(self):
        self.c.force_authenticate(user=self.user2)

        response = self.c.get("/api/accounts/me/")
        self.assertFalse(status.is_success(response.status_code))

    def test_create_account(self):
        response = self.c.post(
            "/api/accounts/",
            {
                "name": "test account",
                "user": self.user.id,
                "contributors": json.dumps([]),
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Account.objects.all()), 4)
        self.assertIsNotNone(Account.objects.get(name="test account"))

    def test_create_account_with_contributors(self):
        constributors = [
            self.user2.username,
        ]

        response = self.c.post(
            "/api/accounts/",
            {
                "name": "test account",
                "user": self.user.id,
                "contributors": json.dumps(constributors),
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Account.objects.all()), 4)
        self.assertIsNotNone(Account.objects.get(name="test account"))
        self.assertEqual(len(AccountUser.objects.all()), 1)
        self.assertIsNotNone(
            AccountUser.objects.get(
                user=self.user2,
                account=Account.objects.get(name="test account"),
            )
        )

    def test_update_account(self):
        response = self.c.patch(
            f"/api/accounts/{self.account.pk}/",
            {
                "name": "second name",
                "contributors": json.dumps([]),
            },
            format="json",
        )

        self.account.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.account.name, "second name")

    def test_update_account_with_contributors(self):
        self.assertEqual(
            len(
                AccountUser.objects.filter(
                    account=self.account, user=self.user2
                )
            ),
            0,
        )

        response = self.c.patch(
            f"/api/accounts/{self.account.pk}/",
            {
                "contributors": json.dumps([self.user2.username]),
            },
            format="json",
        )

        self.account.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(
            len(
                AccountUser.objects.filter(
                    account=self.account, user=self.user2
                )
            ),
            1,
        )

    def test_destroy_account(self):
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )

        AccountUserPermission.objects.create(
            account_user=account_user,
            permissions=Permission.objects.get(codename="delete_account"),
        )

        response = self.c.delete(
            f"/api/accounts/{self.account.pk}/",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Account.objects.all()), 2)

    def test_destroy_account_with_contributors(self):
        account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )

        AccountUserPermission.objects.create(
            account_user=account_user,
            permissions=Permission.objects.get(codename="delete_account"),
        )

        AccountUser.objects.create(account=self.account, user=self.user2)

        response = self.c.delete(
            f"/api/accounts/{self.account.pk}/",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Account.objects.all()), 2)
        self.assertEqual(len(AccountUser.objects.all()), 0)

    def test_destroy_main_account(self):
        response = self.c.delete(
            f"/api/accounts/{self.main_account.pk}/",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertIsNotNone(Account.objects.get(pk=self.main_account.pk))

    def test_set_split_to_false(self):
        self.account.salary_based_split = True
        self.account.save()

        self.account.refresh_from_db()

        self.assertTrue(self.account.salary_based_split)

        response = self.c.post(
            f"/api/accounts/{self.account.pk}/split/",
            {
                "is_slit": "False",
            },
            format="json",
        )

        self.account.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertFalse(self.account.salary_based_split)

    def test_set_split_to_true(self):
        self.user2.profile.salary = 12
        self.user2.profile.save()

        self.assertFalse(self.account.salary_based_split)

        AccountUser.objects.create(
            account=self.account,
            user=self.user2,
            state="APPROVED",
        )

        response = self.c.post(
            f"/api/accounts/{self.account.pk}/split/",
            {
                "is_slit": "True",
            },
            format="json",
        )

        self.account.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertTrue(self.account.salary_based_split)

    def test_set_split_to_true_without_all_salary(self):
        self.assertFalse(self.account.salary_based_split)

        AccountUser.objects.create(
            account=self.account,
            user=self.user2,
            state="APPROVED",
        )

        response = self.c.post(
            f"/api/accounts/{self.account.pk}/split/",
            {
                "is_slit": "True",
            },
            format="json",
        )

        self.account.refresh_from_db()

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(
            response.data["error"],
            "All user in account must have set their salary",
        )

    def test_set_split_with_value_that_is_not_a_bool_representation(self):
        response = self.c.post(
            f"/api/accounts/{self.account.pk}/split/",
            {
                "is_slit": "test",
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(
            response.data["error"],
            "The 'split' field must represent a bool value",
        )

    def test_split_without_split_field(self):
        response = self.c.post(
            f"/api/accounts/{self.account.pk}/split/",
            {},
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(
            response.data["error"],
            "You must include 'split' field",
        )


class ItemViewTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="test", email="test@test.test"
        )
        self.user2 = User.objects.create(
            username="test2", email="test2@test.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)
        self.account2 = Account.objects.create(name="test", user=self.user)
        self.account3 = Account.objects.create(name="test", user=self.user)

        self.account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        self.account_user2 = AccountUser.objects.create(
            account=self.account2, user=self.user
        )
        self.account_user3 = AccountUser.objects.create(
            account=self.account3, user=self.user
        )

        for perm in [
            "add_item",
            "change_item",
            "delete_item",
            "transfert_item",
        ]:
            AccountUserPermission.objects.create(
                account_user=self.account_user,
                permissions=Permission.objects.get(codename=perm),
            )

        AccountUserPermission.objects.create(
            account_user=self.account_user2,
            permissions=Permission.objects.get(codename="transfert_item"),
        )
        AccountUserPermission.objects.create(
            account_user=self.account_user3,
            permissions=Permission.objects.get(codename="transfert_item"),
        )

        self.item = Item.objects.create(
            account=self.account,
            title="test",
            valuation=42.69,
            user=self.user,
        )

        self.category = Category.objects.create(
            title="category",
        )

        self.category_not_under_account = Category.objects.create(
            title="other category",
        )

        self.account_category = AccountCategory.objects.create(
            account=self.account,
            category=self.category,
        )

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_create_item(self):
        self.assertFalse(Item.objects.filter(category=self.category).exists())
        response = self.c.post(
            f"/api/accounts/{self.account.pk}/items/",
            {
                "title": "mon",
                "description": "petit poney",
                "valuation": 12.56,
                "username": self.user.username,
                "category_id": self.category.pk,
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Item.objects.filter(account=self.account)), 2)
        self.assertEqual(
            len(Item.objects.filter(category=self.category)),
            1,
        )

    def test_create_item_without_username(self):
        response = self.c.post(
            f"/api/accounts/{self.account.pk}/items/",
            {
                "title": "mon",
                "valuation": 12.56,
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Item.objects.filter(account=self.account)), 2)

    def test_create_item_with_non_existing_username(self):
        response = self.c.post(
            f"/api/accounts/{self.account.pk}/items/",
            {
                "title": "mon",
                "valuation": 12.56,
                "username": "bad username",
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 404)
        self.assertEqual(len(Item.objects.filter(account=self.account)), 1)

    def test_create_item_with_transfert(self):
        response = self.c.post(
            f"/api/accounts/{self.account.pk}/items/",
            {
                "title": "mon",
                "valuation": 12.56,
                "username": self.user.username,
                "to_account": self.account2.pk,
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Item.objects.filter(account=self.account)), 2)
        self.assertEqual(
            len(Transfert.objects.filter(to_account=self.account2)), 1
        )

    def test_create_item_with_a_category_not_under_account(self):
        with self.assertRaises(AssertionError):
            self.c.post(
                f"/api/accounts/{self.account.pk}/items/",
                {
                    "title": "mon",
                    "description": "petit poney",
                    "valuation": 12.56,
                    "username": self.user.username,
                    "category_id": self.category_not_under_account.pk,
                },
                format="json",
            )

    def test_update_item(self):
        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "description": "petit poney",
                "valuation": 12.56,
                "username": self.user.username,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.item.title, "mon")

    def test_update_item_and_category(self):
        self.assertIsNone(self.item.category)

        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "description": "petit poney",
                "valuation": 12.56,
                "category_id": self.category.pk,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.item.title, "mon")
        self.assertEqual(self.item.category, self.category)

        AccountCategory.objects.create(
            account=self.account,
            category=self.category_not_under_account,
        )

        self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "description": "petit poney",
                "valuation": 12.56,
                "category_id": self.category_not_under_account.pk,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertEqual(self.item.category, self.category_not_under_account)

        self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "description": "petit poney",
                "valuation": 12.56,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertIsNone(self.item.category)

    def test_update_item_with_category_not_under_account(self):
        with self.assertRaises(AssertionError):
            self.c.put(
                f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
                {
                    "title": "mon",
                    "description": "petit poney",
                    "valuation": 12.56,
                    "category_id": self.category_not_under_account.pk,
                },
                format="json",
            )

    def test_update_item_with_another_user_under_item(self):
        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "description": "petit poney",
                "valuation": 12.56,
                "username": self.user2.username,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.item.user, self.user2)

    def test_update_item_with_an_empty_user(self):
        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "valuation": 12.56,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.item.user, None)

    def test_update_item_with_a_non_existing_username(self):
        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "mon",
                "valuation": 12.56,
                "username": "bad username",
            },
            format="json",
        )

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response.status_code, 404)

    def test_update_item_create_transfert(self):
        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "test",
                "description": "description",
                "valuation": 42.69,
                "username": self.user.username,
                "to_account": self.account2.pk,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertIsNotNone(
            Transfert.objects.get(item=self.item, to_account=self.account2)
        )

    def test_update_item_update_transfert(self):
        transfert = Transfert.objects.create(
            item=self.item, to_account=self.account2
        )

        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "test",
                "description": "description",
                "valuation": 42.69,
                "username": self.user.username,
                "to_account": self.account3.pk,
            },
            format="json",
        )

        self.item.refresh_from_db()
        transfert.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(transfert.to_account, self.account3)

    def test_update_item_delete_transfert(self):
        Transfert.objects.create(item=self.item, to_account=self.account2)

        response = self.c.put(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/",
            {
                "title": "test",
                "description": "description",
                "valuation": 42.69,
                "username": self.user.username,
            },
            format="json",
        )

        self.item.refresh_from_db()

        self.assertTrue(status.is_success(response.status_code))
        self.assertIsNone(
            Transfert.objects.filter(
                item=self.item, to_account=self.account2
            ).first()
        )

    def test_delete_items(self):
        response = self.c.delete(
            f"/api/accounts/{self.account.pk}/items/{self.item.pk}/"
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(len(Item.objects.all()), 0)


class AccountUserViewTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="test", email="test@test.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)

        self.account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )

        self.account_user2 = AccountUser.objects.create(
            account=self.account, user=self.user, state="APPROVED"
        )

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_count(self):
        response = self.c.get("/api/account_user/count/")

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(response.data, {"pending_account_request": 1})


class AccountUserPermissionTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="test", email="test@test.test"
        )

        self.user2 = User.objects.create(
            username="test2", email="test2@test.test"
        )

        self.account = Account.objects.create(name="test", user=self.user)
        self.account2 = Account.objects.create(name="test", user=self.user2)

        self.account_user = AccountUser.objects.create(
            account=self.account, user=self.user
        )
        self.account_user2 = AccountUser.objects.create(
            account=self.account2, user=self.user2
        )

        # get permissions instance
        self.add_item_permission = Permission.objects.get(codename="add_item")
        self.change_item_permission = Permission.objects.get(
            codename="change_item"
        )
        self.delete_item_permission = Permission.objects.get(
            codename="delete_item"
        )

        self.account_user_permission = AccountUserPermission.objects.create(
            account_user=self.account_user,
            permissions=self.add_item_permission,
        )
        self.account_user_permission = AccountUserPermission.objects.create(
            account_user=self.account_user,
            permissions=self.change_item_permission,
        )

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_add_permission_to_user_on_account(self):
        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user,
                    permissions=self.delete_item_permission,
                )
            ),
            0,
        )

        response = self.c.post(
            f"/api/accounts/{self.account.pk}/{self.user.username}/permissions/",  # noqa
            {
                "user": "test",
                "permissions": json.dumps(["delete_item"]),
            },
            format="json",
        )
        self.assertTrue(status.is_success(response.status_code))

        self.assertIsNotNone(
            AccountUserPermission.objects.get(
                account_user=self.account_user,
                permissions=self.delete_item_permission,
            ),
        )

        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user2,
                )
            ),
            0,
        )

    def test_remove_permission_to_user_on_account(self):
        AccountUserPermission.objects.create(
            account_user=self.account_user,
            permissions=self.delete_item_permission,
        )

        AccountUserPermission.objects.create(
            account_user=self.account_user2,
            permissions=self.delete_item_permission,
        )

        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user,
                    permissions=self.delete_item_permission,
                )
            ),
            1,
        )

        response = self.c.post(
            f"/api/accounts/{self.account.pk}/{self.user.username}/permissions/",  # noqa
            {
                "user": "test",
                "permissions": json.dumps([]),
            },
            format="json",
        )
        self.assertTrue(status.is_success(response.status_code))

        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user,
                    permissions=self.delete_item_permission,
                )
            ),
            0,
        )

        self.assertIsNotNone(
            AccountUserPermission.objects.get(
                account_user=self.account_user2,
                permissions=self.delete_item_permission,
            ),
        )

    def test_list_account_user_permission(self):
        response = self.c.get(
            f"/api/accounts/{self.account.pk}/{self.user.username}/permissions/"  # noqa
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertIn("add_item", response.data["permissions"])

        response = self.c.get(
            f"/api/accounts/{self.account2.pk}/{self.user2.username}/permissions/"  # noqa
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertNotIn("add_item", response.data["permissions"])

    def test_raise_error_if_accout_user_does_not_exist(self):
        with self.assertRaises(AccountUser.DoesNotExist):
            self.c.get(
                f"/api/accounts/{self.account.pk}/{self.user2.username}/permissions/"  # noqa
            )

    def test_add_and_remove_permission_to_user_on_account(self):
        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user
                )
            ),
            2,
        )

        response = self.c.post(
            f"/api/accounts/{self.account.pk}/{self.user.username}/permissions/",  # noqa
            {
                "user": "test",
                "permissions": json.dumps(["add_item", "delete_item"]),
            },
            format="json",
        )
        self.assertTrue(status.is_success(response.status_code))

        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user
                )
            ),
            2,
        )

        self.assertIsNotNone(
            AccountUserPermission.objects.get(
                account_user=self.account_user,
                permissions=self.add_item_permission,
            )
        )

        self.assertIsNotNone(
            AccountUserPermission.objects.get(
                account_user=self.account_user,
                permissions=self.delete_item_permission,
            )
        )

        self.assertEqual(
            len(
                AccountUserPermission.objects.filter(
                    account_user=self.account_user,
                    permissions=self.change_item_permission,
                )
            ),
            0,
        )


class CategoryViewTest(TestCase):
    def setUp(self):
        self.user = User.objects.create(
            username="jonDoe",
            email="jon@doe.test",
        )

        self.user2 = User.objects.create(
            username="testeur",
            email="test@eur.test",
        )

        self.account = Account.objects.create(
            user=self.user, name="first name", is_main=True
        )

        self.account2 = Account.objects.create(
            user=self.user2, name="first name"
        )

        self.default_category = Category.objects.create(
            title="default_category",
        )

        self.category_for_account = Category.objects.create(
            title="category_for_account",
            content_type=ContentType.objects.get_for_model(Account),
            object_id=self.account,
        )

        self.category_for_account2 = Category.objects.create(
            title="category_for_account2",
            content_type=ContentType.objects.get_for_model(Account),
            object_id=self.account2,
        )

        self.category_for_user = Category.objects.create(
            title="category_for_user",
            content_type=ContentType.objects.get_for_model(User),
            object_id=self.user.pk,
        )

        self.account_category = AccountCategory.objects.create(
            account=self.account,
            category=self.category_for_account,
        )

        self.account2_category = AccountCategory.objects.create(
            account=self.account2,
            category=self.category_for_account2,
        )

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_list_user_category(self):
        """List user categories"""
        response = self.c.get("/api/categories/")

        self.assertFalse(
            any(
                item["title"] == self.default_category.title
                for item in response.data
            )
        )
        self.assertFalse(
            any(
                item["title"] == self.category_for_account.title
                for item in response.data
            )
        )
        self.assertFalse(
            any(
                item["title"] == self.category_for_account2.title
                for item in response.data
            )
        )
        self.assertTrue(
            any(
                item["title"] == self.category_for_user.title
                for item in response.data
            )
        )

    def test_list_account_category_own_account(self):
        """List default categories, account categories and own categories"""
        response = self.c.get(f"/api/categories/?account={self.account.pk}")

        self.assertTrue(
            any(
                item["title"] == self.default_category.title
                for item in response.data
            )
        )
        self.assertTrue(
            any(
                item["title"] == self.category_for_account.title
                for item in response.data
            )
        )
        self.assertFalse(
            any(
                item["title"] == self.category_for_account2.title
                for item in response.data
            )
        )
        self.assertTrue(
            any(
                item["title"] == self.category_for_user.title
                for item in response.data
            )
        )

    def test_list_account_category_on_none_own_account(self):
        """List account categories (don't depend on the category content_type)"""  # noqa
        response = self.c.get(f"/api/categories/?account={self.account2.pk}")

        self.assertFalse(
            any(
                item["title"] == self.default_category.title
                for item in response.data
            )
        )
        self.assertFalse(
            any(
                item["title"] == self.category_for_account.title
                for item in response.data
            )
        )
        self.assertTrue(
            any(
                item["title"] == self.category_for_account2.title
                for item in response.data
            )
        )
        self.assertFalse(
            any(
                item["title"] == self.category_for_user.title
                for item in response.data
            )
        )

    def test_create_account_category(self):
        category_count = Category.objects.filter(
            object_id=self.account.pk
        ).count()

        account_category_count = AccountCategory.objects.filter(
            account=self.account
        ).count()

        self.c.post(
            "/api/categories/",
            {
                "title": "new title",
                "account_id": self.account.pk,
            },
            format="json",
        )

        self.assertEqual(
            Category.objects.filter(object_id=self.account.pk).count(),
            category_count + 1,
        )

        self.assertEqual(
            AccountCategory.objects.filter(account=self.account).count(),
            account_category_count + 1,
        )

    def test_update_account_category(self):
        self.c.put(
            f"/api/categories/{self.category_for_account.pk}/",
            {
                "title": "new title",
            },
            format="json",
        )

        self.category_for_account.refresh_from_db()

        self.assertEqual(self.category_for_account.title, "new title")

    def test_update_content_type_account_category(self):
        self.c.put(
            f"/api/categories/{self.category_for_account.pk}/",
            {
                "content_type": ContentType.objects.get_for_model(User).pk,
            },
            format="json",
        )

        self.category_for_account.refresh_from_db()

        self.assertEqual(
            self.category_for_account.content_type,
            ContentType.objects.get_for_model(Account),
        )

    def test_create_user_category(self):
        user_category_count = Category.objects.filter(
            object_id=self.user.pk
        ).count()

        self.c.post(
            "/api/categories/",
            {
                "title": "new title",
            },
            format="json",
        )

        self.assertEqual(
            Category.objects.filter(object_id=self.user.pk).count(),
            user_category_count + 1,
        )

    def test_update_user_category(self):
        self.c.put(
            f"/api/categories/{self.category_for_user.pk}/",
            {
                "title": "new title",
            },
            format="json",
        )

        self.category_for_user.refresh_from_db()

        self.assertEqual(self.category_for_user.title, "new title")

    def test_delete_category(self):
        user_category_count = Category.objects.all().count()

        self.c.delete(f"/api/categories/{self.category_for_user.pk}/")

        self.assertEqual(
            Category.objects.all().count(),
            user_category_count - 1,
        )
