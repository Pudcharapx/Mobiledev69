# Mobile Dev 69

This branch contains the Week 12 authentication lab as four independent apps.

| Folder | Purpose | Default port |
| --- | --- | --- |
| `backend1` | Django REST API protected by Simple JWT | 8000 |
| `frontend1` | Flutter Web login and protected-API client | 50001 |
| `backend2` | Django OpenID Connect Provider | 8001 |
| `frontend2` | Flutter Web OpenID Connect client | 50000 |

Follow the `README.md` in each folder to start it. Start `backend1` before
`frontend1`; start `backend2`, create a Django user, and run
`bootstrap_oidc` before `frontend2`.
