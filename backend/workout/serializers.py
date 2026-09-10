from rest_framework import serializers
from .models import Exercise, WorkoutLog


class ExerciseSerializer(serializers.ModelSerializer):
    """
    Read-only serializer for Exercise matching SRS section 4.1.
    """

    class Meta:
        model = Exercise
        fields = [
            "id",
            "name",
            "primary_muscle",
            "secondary_muscles",
            "contribution_weight",
        ]
        read_only_fields = fields


class WorkoutLogSerializer(serializers.ModelSerializer):
    """
    Serializer for WorkoutLog matching SRS section 4.2.
    `user_id` is automatically set to the authenticated user and read-only.
    """

    user_id = serializers.PrimaryKeyRelatedField(read_only=True)
    exercise_id = serializers.PrimaryKeyRelatedField(
        queryset=Exercise.objects.all()
    )

    class Meta:
        model = WorkoutLog
        fields = [
            "id",
            "user_id",
            "exercise_id",
            "date",
            "sets",
            "reps",
            "weight_kg",
            "note",
        ]

    def to_internal_value(self, data):
        # Support both 'exercise' and 'exercise_id' in incoming payload
        if "exercise" in data and "exercise_id" not in data:
            data = data.copy() if hasattr(data, "copy") else dict(data)
            data["exercise_id"] = data["exercise"]
        return super().to_internal_value(data)
