from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from django.core.management.base import BaseCommand
from oidc_provider.models import Client, RSAKey, ResponseType


class Command(BaseCommand):
    help = "Bootstrap OIDC provider client and RSA key for Flutter application"

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
            client_id="muscledev-frontend"
        )
        client.name = "Muscle Heatmap Frontend"
        client.client_type = "public"
        client.jwt_alg = "RS256"
        # django-oidc-provider stores one URI per line.  Use the model
        # properties so rerunning this command also repairs existing clients.
        client.redirect_uris = [
            "http://localhost:50000/callback",
            "http://localhost:50000/",
        ]
        client.post_logout_redirect_uris = ["http://localhost:50000/"]
        client._scope = "openid profile email"
        client.require_consent = False
        client.save()
        client.response_types.set(response_types)

        if not RSAKey.objects.exists():
            private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
            pem = private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.PKCS8,
                encryption_algorithm=serialization.NoEncryption(),
            ).decode("utf-8")
            RSAKey.objects.create(key=pem)
            self.stdout.write(self.style.SUCCESS("Created RSA signing key for OIDC."))

        action = "Created" if created else "Updated"
        self.stdout.write(self.style.SUCCESS(f"{action} OIDC public client: {client.client_id}"))

        from django.contrib.auth.models import User

        demo_user, u_created = User.objects.get_or_create(
            username="demouser",
            defaults={"email": "demo@example.com", "first_name": "Demo", "last_name": "User"},
        )
        demo_user.set_password("demo12345")
        demo_user.save()
        self.stdout.write(self.style.SUCCESS("Ensured demo user exists: demouser / demo12345"))
