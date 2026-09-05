# Frontend 1 — Flutter JWT client

Run Backend 1 at `http://127.0.0.1:8000`, then run this as a Web app:

```powershell
flutter pub get
flutter run -d chrome --web-port 50001
```

Sign in using a Django user created in Backend 1. The app gets a JWT from
`/api/token/` and uses it to read the protected `/api/bookings/` endpoint.
