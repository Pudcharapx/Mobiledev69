from django.contrib import admin
from django.contrib.auth import views as auth_views
from django.urls import include, path

urlpatterns = [
    path(
        "login/",
        auth_views.LoginView.as_view(template_name="registration/login.html"),
        name="login",
    ),
    path("admin/", admin.site.urls),
    path("api/", include("workout.urls")),
    path("", include("oidc_provider.urls", namespace="oidc_provider")),
]
