from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import check_password, make_password
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


class ProfileViewTest(TestCase):
    def setUp(cls):
        pass


class RegisterViewTest(TestCase):
    def setUp(cls):
        pass


class ItemViewTest(TestCase):
    def setUp(cls):
        pass


class AccountViewTest(TestCase):
    def setUp(cls):
        pass
