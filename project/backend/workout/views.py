from rest_framework import permissions, viewsets
from .models import Exercise, WorkoutLog
from .serializers import ExerciseSerializer, WorkoutLogSerializer


class ExerciseViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Read-only endpoint for Exercise list and detail.
    Accessible to authenticated users (and read-only requests).
    """

    queryset = Exercise.objects.all().order_by("id")
    serializer_class = ExerciseSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]


class WorkoutLogViewSet(viewsets.ModelViewSet):
    """
    Full CRUD endpoint for WorkoutLog.
    Scoped strictly to the authenticated user:
    - User only sees their own workout logs.
    - User can only update or delete their own workout logs.
    - User cannot see or modify other users' workout logs.
    - Created logs automatically assign request.user as user_id.
    """

    serializer_class = WorkoutLogSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if not user.is_authenticated:
            return WorkoutLog.objects.none()
        return WorkoutLog.objects.filter(user_id=user).order_by("-date", "-id")

    def perform_create(self, serializer):
        serializer.save(user_id=self.request.user)
