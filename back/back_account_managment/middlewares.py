import hashlib
import hmac
import json

from django.conf import settings
from django.http import JsonResponse


def verify_hmac(request):
    client_signature = request.headers.get("X-Signature")

    if client_signature is None:
        return False

    body = request.body
    method = request.method
    uri = request.path_info.replace("/api/", "")
    content_type = request.content_type

    concat_string = (
        (
            f"{method}&{uri}&{content_type}"
            if body == b""
            else f"{method}&{uri}&{content_type}&{json.loads(body)}"
        )
        .replace("'", '"')
        .replace(": ", ":")
    )

    computed_signature = hmac.new(
        key=settings.SECRET_API_KEY.encode(),
        msg=concat_string.encode(),
        digestmod=hashlib.sha256,
    ).hexdigest()

    return hmac.compare_digest(client_signature, computed_signature)


class HMACMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if not verify_hmac(request):
            return JsonResponse({"error": "Invalid request"}, status=403)

        return self.get_response(request)
