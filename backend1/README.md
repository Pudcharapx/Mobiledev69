# Backend 1 — Django REST + JWT

## Run

```powershell
uv sync
uv run python manage.py migrate
uv run python manage.py createsuperuser
uv run python manage.py runserver 8000
```

Use the account you created to obtain a token:

```powershell
http POST :8000/api/token/ username=YOUR_USERNAME password=YOUR_PASSWORD
http POST :8000/api/token/refresh/ refresh=YOUR_REFRESH_TOKEN
```

`GET /api/bookings/` requires `Authorization: Bearer <access token>`.
