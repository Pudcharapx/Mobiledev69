from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from django.core.management.base import BaseCommand
from oidc_provider.models import Client, RSAKey, ResponseType


class Command(BaseCommand):
    help = "Create the local Flutter Web OIDC client and an RSA signing key."

    def handle(self, *args, **options):
        response_types = []
        for value, description in [
            ("code", "code (Authorization Code Flow)"),
            ("id_token token", "id_token token (Implicit Flow)"),
        ]:
            response_type, _ = ResponseType.objects.get_or_create(
                value=value, defaults={"description": description}
            )
            response_types.append(response_type)
        client, created = Client.objects.get_or_create(
            client_id="mobiledev-frontend2",
            defaults={
                "name": "MobileDev Frontend 2",
                "client_type": "public",
                "jwt_alg": "RS256",
                "_redirect_uris": "http://localhost:50000",
                "_post_logout_redirect_uris": "http://localhost:50000",
                "_scope": "openid profile email",
                "require_consent": False,
            },
        )
        client.response_types.add(*response_types)

        if not RSAKey.objects.exists():
            private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
            pem = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption(),
            ).decode("utf-8")
            RSAKey.objects.create(key=pem)
            self.stdout.write(self.style.SUCCESS("Created an RSA signing key."))

        action = "Created" if created else "Kept existing"
        self.stdout.write(self.style.SUCCESS(f"{action} client: {client.client_id}"))
