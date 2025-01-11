import hashlib
import hmac
import json

from back_account_managment.models import Log, LogCode
from django.conf import settings
from django.http import JsonResponse


def verify_hmac(request):
    client_signature = request.headers.get("X-Signature")

    if client_signature is None:
        return False, "", ""

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

    return (
        hmac.compare_digest(client_signature, computed_signature),
        concat_string,
        computed_signature,
    )


class HMACMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        verified_hmac, concat_string, computed_signature = verify_hmac(request)

        if verified_hmac is False:
            Log.objects.create(
                code=LogCode.INVALID_SIGNATURE,
                details={
                    "client signature": request.headers.get("X-Signature"),
                    "body": json.loads(request.body),
                    "method": request.method,
                    "uri": request.path_info,
                    "content type": request.content_type,
                    "concat string": concat_string,
                    "computed signature": computed_signature,
                },
            )

            return JsonResponse({"error": "Invalid request"}, status=403)

        return self.get_response(request)
