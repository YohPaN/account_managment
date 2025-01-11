import json
from unittest.mock import MagicMock, patch

from back_account_managment.middlewares import HMACMiddleware, verify_hmac
from back_account_managment.models import Log
from django.test import TestCase, override_settings
from rest_framework import status
from rest_framework.test import APIRequestFactory


class HMACMiddlewareTest(TestCase):
    def setUp(cls):
        cls.get_response = MagicMock()
        cls.factory = APIRequestFactory()
        cls.request = cls.factory.get(
            "/api/test/",
            content_type="application/json",
            headers={
                "X-Signature": "72022d86609633691e568f82ee05dfe8dcb64a0350cabb775dc75f2c9d9de040"  # noqa
            },
        )

    @override_settings(SECRET_API_KEY="test_signature")
    def test_verify_hmac(self):
        self.assertTrue(verify_hmac(self.request)[0])

    @override_settings(SECRET_API_KEY="other_signature")
    def test_verify_hmac_with_bad_signature(self):
        self.assertFalse(verify_hmac(self.request)[0])

    def test_verify_hmac_without_signature(self):
        del self.request.META["HTTP_X_SIGNATURE"]
        self.assertFalse(verify_hmac(self.request)[0])

    def test_verify_hmac_with_body(self):
        request = self.factory.post(
            "/api/test/",
            '{"title": "new test"}',
            content_type="application/json",
            headers={
                "X-Signature": "887f3c89689b7acf6c024f3d578558a9fa15f03eae5fdb2526f86bf45564b324"  # noqa
            },
        )

        self.assertTrue(verify_hmac(request)[0])

    @patch("back_account_managment.middlewares.verify_hmac")
    def test_call_method_of_HMACMiddleware_class(self, mock_method):
        mock_method.return_value = (True, "", "")

        middleware = HMACMiddleware(self.get_response)
        response = middleware(self.request)

        mock_method.assert_called_once_with(self.request)

        self.assertEqual(self.get_response.return_value, response)

    @patch("back_account_managment.middlewares.verify_hmac")
    def test_call_method_of_HMACMiddleware_class_unverified_signature(
        self, mock_method
    ):
        self.assertEqual(Log.objects.all().count(), 0)

        mock_method.return_value = (
            False,
            'POST&test/&application/json&{"title": "new test"}',
            "computed signature",
        )

        request = self.factory.post(
            "/api/test/",
            '{"title": "new test"}',
            content_type="application/json",
            headers={
                "X-Signature": "887f3c89689b7acf6c024f3d578558a9fa15f03eae5fdb2526f86bf45564b324"  # noqa
            },
        )

        expected_description_json = {
            "client signature": "887f3c89689b7acf6c024f3d578558a9fa15f03eae5fdb2526f86bf45564b324",  # noqa
            "body": {"title": "new test"},
            "method": "POST",
            "uri": "/api/test/",
            "content type": "application/json",
            "concat string": 'POST&test/&application/json&{"title": "new test"}',  # noqa
            "computed signature": "computed signature",
        }

        middleware = HMACMiddleware(self.get_response)
        response = middleware(request)

        response_content = json.loads(response.content)

        mock_method.assert_called_once_with(request)

        self.assertFalse(status.is_success(response.status_code))
        self.assertEqual(response_content["error"], "Invalid request")
        self.assertEqual(Log.objects.all().count(), 1)
        self.assertEqual(Log.objects.first().code, "INVALID_SIGNATURE")
        self.assertEqual(
            Log.objects.first().details, expected_description_json
        )
