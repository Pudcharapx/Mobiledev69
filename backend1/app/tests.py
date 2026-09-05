from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient


class TokenAndBookingTests(TestCase):
    def setUp(self):
        self.user = get_user_model().objects.create_user(
            username="demo", password="demo-password", email="demo@example.com"
        )
        self.client = APIClient()

    def test_token_refresh_and_protected_api(self):
        response = self.client.post(
            "/api/token/", {"username": "demo", "password": "demo-password"}, format="json"
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["access"].count("."), 2)
        self.assertEqual(response.data["refresh"].count("."), 2)

        self.assertEqual(self.client.get("/api/bookings/").status_code, 401)
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")
        self.assertEqual(self.client.get("/api/bookings/").status_code, 200)

        refresh_response = self.client.post(
            "/api/token/refresh/", {"refresh": response.data["refresh"]}, format="json"
        )
        self.assertEqual(refresh_response.status_code, 200)
        self.assertIn("access", refresh_response.data)

# Create your tests here.
