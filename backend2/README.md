# Backend 2 — Django OpenID Connect Provider

## First run

```powershell
uv sync
uv run python manage.py migrate
uv run python manage.py createsuperuser
uv run python manage.py bootstrap_oidc
uv run python manage.py runserver 8001
```

The bootstrap command creates a public client named `mobiledev-frontend2`, its
redirect URI `http://localhost:50000`, and the RSA key used to sign ID tokens.

Check the provider endpoints:

```powershell
http :8001/.well-known/openid-configuration
http :8001/jwks/
```

Use the Django admin at `/admin/` to manage users and OIDC clients.
