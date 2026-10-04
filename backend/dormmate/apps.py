from django.apps import AppConfig


class DormMateConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'dormmate'

    def ready(self):
        try:
            from oidc_provider.lib.endpoints.authorize import AuthorizeEndpoint
            # Allow public PKCE clients with require_consent=False to skip consent screen
            AuthorizeEndpoint.is_client_allowed_to_skip_consent = lambda self: True
        except ImportError:
            pass
