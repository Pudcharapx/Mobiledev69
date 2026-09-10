from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("workout.urls")),
    path("", include("oidc_provider.urls", namespace="oidc_provider")),
]
