from datetime import date, timedelta
from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.test import TestCase
from django.utils import timezone
from oidc_provider.models import Client, Token
from rest_framework import status
from rest_framework.test import APIClient
from workout.models import Exercise, WorkoutLog, WeeklyGoal

User = get_user_model()


class ModelFieldSpecificationTests(TestCase):
    def test_exercise_fields_match_srs_4_1(self):
        """Verify Exercise model has exactly the fields from SRS 4.1."""
        field_names = [f.name for f in Exercise._meta.fields]
        expected_fields = ["id", "name", "primary_muscle", "secondary_muscles", "contribution_weight"]
        self.assertEqual(field_names, expected_fields)

    def test_workoutlog_fields_match_srs_4_2(self):
        """Verify WorkoutLog model has exactly the fields from SRS 4.2."""
        field_names = [f.name for f in WorkoutLog._meta.fields]
        expected_fields = ["id", "date", "sets", "reps", "weight_kg", "note", "exercise_id", "user_id"]
        self.assertCountEqual(field_names, expected_fields)

    def test_weeklygoal_fields_match_srs_4_3(self):
        """Verify WeeklyGoal model has exactly the fields from SRS 4.3."""
        field_names = [f.name for f in WeeklyGoal._meta.fields]
        expected_fields = ["id", "muscle_group", "target_sets_per_week", "user_id"]
        self.assertCountEqual(field_names, expected_fields)


class ExerciseSeedDataTests(TestCase):
    EXPECTED_EXERCISES = [
        (1, "Bench Press", "chest", ["shoulders", "triceps"], {"chest": 1.0, "shoulders": 0.5, "triceps": 0.5}),
        (2, "Incline Dumbbell Press", "chest", ["shoulders", "triceps"], {"chest": 1.0, "shoulders": 0.5, "triceps": 0.5}),
        (3, "Push-up", "chest", ["shoulders", "triceps", "core"], {"chest": 1.0, "shoulders": 0.5, "triceps": 0.5, "core": 0.5}),
        (4, "Pull-up", "back", ["biceps", "shoulders"], {"back": 1.0, "biceps": 0.5, "shoulders": 0.5}),
        (5, "Lat Pulldown", "back", ["biceps"], {"back": 1.0, "biceps": 0.5}),
        (6, "Barbell Row", "back", ["biceps", "shoulders"], {"back": 1.0, "biceps": 0.5, "shoulders": 0.5}),
        (7, "Deadlift", "back", ["glutes", "hamstrings", "core"], {"back": 1.0, "glutes": 0.5, "hamstrings": 0.5, "core": 0.5}),
        (8, "Overhead Press", "shoulders", ["triceps", "chest"], {"shoulders": 1.0, "triceps": 0.5, "chest": 0.5}),
        (9, "Lateral Raise", "shoulders", [], {"shoulders": 1.0}),
        (10, "Face Pull", "shoulders", ["back"], {"shoulders": 1.0, "back": 0.5}),
        (11, "Barbell Squat", "legs", ["glutes", "core"], {"legs": 1.0, "glutes": 0.5, "core": 0.5}),
        (12, "Leg Press", "legs", ["glutes"], {"legs": 1.0, "glutes": 0.5}),
        (13, "Romanian Deadlift", "hamstrings", ["glutes", "back"], {"hamstrings": 1.0, "glutes": 0.5, "back": 0.5}),
        (14, "Lunge", "legs", ["glutes"], {"legs": 1.0, "glutes": 0.5}),
        (15, "Bicep Curl", "biceps", [], {"biceps": 1.0}),
        (16, "Triceps Pushdown", "triceps", [], {"triceps": 1.0}),
        (17, "Plank", "core", ["shoulders"], {"core": 1.0, "shoulders": 0.5}),
        (18, "Hanging Leg Raise", "core", [], {"core": 1.0}),
    ]

    def test_seed_exercises_count(self):
        """Verify exactly 18 exercises are loaded on migrate."""
        self.assertEqual(Exercise.objects.count(), 18)

    def test_seed_exercises_exact_values(self):
        """Verify all 18 exercises match SRS section 6 exact values."""
        for pk, name, primary, secondary, weights in self.EXPECTED_EXERCISES:
            exercise = Exercise.objects.get(pk=pk)
            self.assertEqual(exercise.name, name)
            self.assertEqual(exercise.primary_muscle, primary)
            self.assertEqual(exercise.secondary_muscles, secondary)
            self.assertEqual(exercise.contribution_weight, weights)

    def test_loaddata_idempotency(self):
        """Verify running loaddata multiple times is idempotent."""
        call_command("loaddata", "exercises", verbosity=0)
        self.assertEqual(Exercise.objects.count(), 18)


class WorkoutLogModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="password123")
        self.exercise = Exercise.objects.get(name="Push-up")

    def test_create_workout_log_with_nullable_fields(self):
        log = WorkoutLog.objects.create(
            user_id=self.user,
            exercise_id=self.exercise,
            date=date(2026, 9, 10),
            sets=3,
            reps=15,
            weight_kg=None,
            note=None,
        )
        self.assertIsNotNone(log.id)
        self.assertEqual(log.user_id, self.user)
        self.assertEqual(log.exercise_id, self.exercise)
        self.assertEqual(log.sets, 3)
        self.assertEqual(log.reps, 15)
        self.assertIsNone(log.weight_kg)
        self.assertIsNone(log.note)

    def test_create_workout_log_with_all_fields(self):
        log = WorkoutLog.objects.create(
            user_id=self.user,
            exercise_id=self.exercise,
            date=date(2026, 9, 10),
            sets=4,
            reps=8,
            weight_kg=80.5,
            note="Felt strong today",
        )
        self.assertEqual(log.weight_kg, 80.5)
        self.assertEqual(log.note, "Felt strong today")
        self.assertIn("Push-up", str(log))


class WeeklyGoalModelTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(username="testuser", password="password123")

    def test_create_weekly_goal(self):
        goal = WeeklyGoal.objects.create(
            user_id=self.user,
            muscle_group="chest",
            target_sets_per_week=12,
        )
        self.assertIsNotNone(goal.id)
        self.assertEqual(goal.user_id, self.user)
        self.assertEqual(goal.muscle_group, "chest")
        self.assertEqual(goal.target_sets_per_week, 12)
        self.assertIn("chest", str(goal))


class ExerciseAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username="exercise_tester", password="password")

    def test_list_exercises(self):
        """GET /api/exercises/ returns all 18 seed exercises."""
        response = self.client.get("/api/exercises/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 18)

    def test_retrieve_exercise(self):
        """GET /api/exercises/1/ returns the Bench Press exercise details."""
        response = self.client.get("/api/exercises/1/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["name"], "Bench Press")
        self.assertEqual(response.data["primary_muscle"], "chest")

    def test_create_exercise_disallowed(self):
        """POST /api/exercises/ is not allowed (read-only endpoint)."""
        self.client.force_authenticate(user=self.user)
        response = self.client.post("/api/exercises/", {"name": "Custom Exercise"})
        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)

    def test_update_exercise_disallowed(self):
        """PUT /api/exercises/1/ is not allowed (read-only endpoint)."""
        self.client.force_authenticate(user=self.user)
        response = self.client.put("/api/exercises/1/", {"name": "Modified"})
        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)

    def test_delete_exercise_disallowed(self):
        """DELETE /api/exercises/1/ is not allowed (read-only endpoint)."""
        self.client.force_authenticate(user=self.user)
        response = self.client.delete("/api/exercises/1/")
        self.assertEqual(response.status_code, status.HTTP_405_METHOD_NOT_ALLOWED)


class WorkoutLogAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user_a = User.objects.create_user(username="user_a", password="password_a")
        self.user_b = User.objects.create_user(username="user_b", password="password_b")
        self.exercise = Exercise.objects.get(pk=1)  # Bench Press

        # User A's log
        self.log_a = WorkoutLog.objects.create(
            user_id=self.user_a,
            exercise_id=self.exercise,
            date=date(2026, 9, 10),
            sets=3,
            reps=10,
            weight_kg=60.0,
            note="User A log",
        )
        # User B's log
        self.log_b = WorkoutLog.objects.create(
            user_id=self.user_b,
            exercise_id=self.exercise,
            date=date(2026, 9, 10),
            sets=4,
            reps=12,
            weight_kg=70.0,
            note="User B log",
        )

    def test_unauthenticated_request_rejected(self):
        """Unauthenticated requests must receive 401 Unauthorized."""
        response = self.client.get("/api/workout-logs/")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_list_logs_scoped_to_user_a(self):
        """User A must only see their own logs, never User B's logs."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.get("/api/workout-logs/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["id"], self.log_a.id)
        self.assertEqual(response.data[0]["user_id"], self.user_a.id)

    def test_list_logs_scoped_to_user_b(self):
        """User B must only see their own logs, never User A's logs."""
        self.client.force_authenticate(user=self.user_b)
        response = self.client.get("/api/workout-logs/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["id"], self.log_b.id)
        self.assertEqual(response.data[0]["user_id"], self.user_b.id)

    def test_retrieve_own_log_succeeds(self):
        """User A can retrieve their own log."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.get(f"/api/workout-logs/{self.log_a.id}/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["id"], self.log_a.id)

    def test_retrieve_other_user_log_returns_404(self):
        """User A trying to retrieve User B's log gets 404 (scoped query)."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.get(f"/api/workout-logs/{self.log_b.id}/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_create_log_auto_assigns_authenticated_user(self):
        """Creating a workout log automatically sets user_id to request.user."""
        self.client.force_authenticate(user=self.user_a)
        payload = {
            "exercise_id": self.exercise.id,
            "date": "2026-09-11",
            "sets": 5,
            "reps": 5,
            "weight_kg": 80.0,
            "note": "Heavy sets",
            "user_id": self.user_b.id,  # Attempting to spoof User B
        }
        response = self.client.post("/api/workout-logs/", payload)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        # Verify user_id is User A, NOT User B
        self.assertEqual(response.data["user_id"], self.user_a.id)
        created_log = WorkoutLog.objects.get(id=response.data["id"])
        self.assertEqual(created_log.user_id, self.user_a)

    def test_update_own_log_succeeds(self):
        """User A can update their own log."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.patch(
            f"/api/workout-logs/{self.log_a.id}/",
            {"sets": 6, "note": "Updated note"},
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.log_a.refresh_from_db()
        self.assertEqual(self.log_a.sets, 6)
        self.assertEqual(self.log_a.note, "Updated note")

    def test_update_other_user_log_returns_404(self):
        """User A trying to update User B's log gets 404."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.patch(
            f"/api/workout-logs/{self.log_b.id}/",
            {"sets": 10},
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_delete_own_log_succeeds(self):
        """User A can delete their own log."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.delete(f"/api/workout-logs/{self.log_a.id}/")
        self.assertEqual(response.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(WorkoutLog.objects.filter(id=self.log_a.id).exists())

    def test_delete_other_user_log_returns_404(self):
        """User A trying to delete User B's log gets 404."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.delete(f"/api/workout-logs/{self.log_b.id}/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertTrue(WorkoutLog.objects.filter(id=self.log_b.id).exists())

    def test_workouts_alias_endpoint(self):
        """The /api/workouts/ alias functions identically to /api/workout-logs/."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.get("/api/workouts/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    def test_weekly_goal_not_implemented_yet(self):
        """WeeklyGoal endpoints should not be implemented in this task."""
        self.client.force_authenticate(user=self.user_a)
        response = self.client.get("/api/weekly-goals/")
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


class OIDCAuthenticationAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username="oidc_user", password="password")
        self.oidc_client = Client.objects.create(
            client_id="test-client",
            client_type="public",
            jwt_alg="RS256",
        )

    def test_valid_bearer_token_authenticates(self):
        """A valid OIDC Bearer token authenticates the request and scopes user data."""
        token = Token.objects.create(
            user=self.user,
            client=self.oidc_client,
            access_token="valid-token-12345",
            expires_at=timezone.now() + timedelta(hours=1),
            scope=["openid", "profile"],
        )
        response = self.client.get(
            "/api/workout-logs/",
            HTTP_AUTHORIZATION="Bearer valid-token-12345",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_expired_bearer_token_rejected(self):
        """An expired OIDC Bearer token returns 401."""
        Token.objects.create(
            user=self.user,
            client=self.oidc_client,
            access_token="expired-token-12345",
            expires_at=timezone.now() - timedelta(hours=1),
            scope=["openid", "profile"],
        )
        response = self.client.get(
            "/api/workout-logs/",
            HTTP_AUTHORIZATION="Bearer expired-token-12345",
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_invalid_bearer_token_rejected(self):
        """An unknown OIDC Bearer token returns 401."""
        response = self.client.get(
            "/api/workout-logs/",
            HTTP_AUTHORIZATION="Bearer non-existent-token",
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
