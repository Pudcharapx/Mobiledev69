# Frontend 2 — Flutter Web OIDC client

Start Backend 2 and run its `bootstrap_oidc` command first. Then use the exact
redirect origin registered for the client:

```powershell
flutter pub get
flutter run -d chrome --web-port 50000
```

Press **Sign in with Backend 2**. The browser is redirected to the Django OIDC
provider. Sign in using a Backend 2 Django user, then it returns to this app
and displays the ID-token claims.
