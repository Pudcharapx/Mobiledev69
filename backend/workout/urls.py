from django.urls import include, path
from rest_framework.routers import DefaultRouter
from .views import ExerciseViewSet, WorkoutLogViewSet

router = DefaultRouter()
router.register(r"exercises", ExerciseViewSet, basename="exercise")
router.register(r"workout-logs", WorkoutLogViewSet, basename="workout-log")
router.register(r"workouts", WorkoutLogViewSet, basename="workout")

urlpatterns = [
    path("", include(router.urls)),
]
