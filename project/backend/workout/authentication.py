from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from oidc_provider.models import Token


class OIDCAuthentication(BaseAuthentication):
    """
    Custom DRF authentication class that validates Bearer access tokens
    issued by django-oidc-provider.
    """

    def authenticate_header(self, request):
        return 'Bearer realm="api"'

    def authenticate(self, request):
        auth_header = request.headers.get("Authorization")
        if not auth_header:
            return None

        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            return None

        raw_token = parts[1]
        try:
            token = Token.objects.select_related("user").get(access_token=raw_token)
        except Token.DoesNotExist:
            raise AuthenticationFailed("Invalid access token.")

        if token.has_expired():
            raise AuthenticationFailed("Access token has expired.")

        return (token.user, token)
