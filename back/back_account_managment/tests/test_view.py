import json

from back_account_managment.models import Profile
from back_account_managment.views import Account, AccountUser
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password
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
        self.user.set_password("password"),

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_get_current_user(self):
        excepted_response = {
            "username": "jonDoe",
            "email": "jon@doe.test",
            "profile": None,
        }
        response = self.c.get("/api/users/me/")
        self.assertTrue(status.is_success(response.status_code))

        self.assertIn("username", response.data)
        self.assertIn("email", response.data)
        self.assertIn("profile", response.data)
        self.assertEqual(excepted_response, response.data)
        self.assertEqual(response.data["username"], "jonDoe")
        self.assertEqual(response.data["email"], "jon@doe.test")
        self.assertIsNone(response.data["profile"])

    def test_update_profile(self):
        excepted_response = {
            "username": "JonTheRipper",
            "email": "jon@the.ripper",
        }

        response = self.c.patch(
            "/api/users/me/update/",
            {
                "username": "JonTheRipper",
                "email": "jon@the.ripper",
            },
            format="json",
        )

        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(self.user.username, "JonTheRipper")
        self.assertEqual(self.user.email, "jon@the.ripper")
        self.assertIn("username", response.data)
        self.assertIn("email", response.data)
        self.assertEqual(response.data, excepted_response)

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


class RegisterViewTest(TestCase):
    def setUp(self):
        self.c = APIClient()

    def test_register(self):
        self.assertEqual(len(User.objects.all()), 0)

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

        self.assertTrue(status.is_client_error(response.status_code))
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

        self.assertTrue(status.is_client_error(response.status_code))
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

        self.c = APIClient()
        self.c.force_authenticate(user=self.user)

    def test_get_context(self):
        # TODO: find a way to test get_serializer_context
        # factory = APIRequestFactory()
        # request = factory.get("/")

        # account_view = AccountView(request=request)
        # context = account_view.get_serializer_context()
        # self.assertNotIn("request", context)

        # account_view.get_serializer_context()
        pass

    def test_list(self):
        [
            Account.objects.create(id=i + 1, name="test", user=self.user)
            for i in range(2)
        ]
        account = Account.objects.create(id=3, name="test", user=self.user2)

        AccountUser.objects.create(account=account, user=self.user)

        response = self.c.get("/api/accounts/")

        self.assertTrue(status.is_success(response.status_code))
        self.assertIn("own", response.data)
        self.assertIn("contributor_account", response.data)
        self.assertEqual(len(response.data["own"]), 2)
        self.assertEqual(len(response.data["contributor_account"]), 1)

    def test_get_current_user_account(self):
        account = Account.objects.create(
            id=3,
            name="test",
            user=self.user,
            is_main=True,
        )

        response = self.c.get("/api/accounts/me/")
        self.assertTrue(status.is_success(response.status_code))
        self.assertEqual(response.data["id"], account.pk)

    def test_no_account_get_current_user_account(self):
        response = self.c.get("/api/accounts/me/")
        self.assertTrue(status.is_client_error(response.status_code))

    def test_create_account(self):
        self.assertEqual(len(Account.objects.all()), 0)
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
        self.assertEqual(len(Account.objects.all()), 1)
        self.assertIsNotNone(Account.objects.get(name="test account"))

    def test_create_account_with_contributors(self):
        self.assertEqual(len(Account.objects.all()), 0)

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
        self.assertEqual(len(Account.objects.all()), 1)
        self.assertIsNotNone(Account.objects.get(name="test account"))
        self.assertEqual(len(AccountUser.objects.all()), 1)
        self.assertIsNotNone(
            AccountUser.objects.get(
                user=self.user2,
                account=Account.objects.get(name="test account"),
            )
        )
