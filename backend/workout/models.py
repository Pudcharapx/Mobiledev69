from django.conf import settings
from django.db import models


class Exercise(models.Model):
    """
    SRS 4.1: Exercise (seed data — pre-loaded, not entered by users)
    Fields:
      - id: primary key
      - name: Exercise name, e.g. "Bench Press"
      - primary_muscle: Main muscle trained, e.g. "chest"
      - secondary_muscles: Secondary muscles list/JSON, e.g. ["shoulders", "triceps"]
      - contribution_weight: Weighting per muscle group JSON, e.g. {"chest": 1.0, "shoulders": 0.5, "triceps": 0.5}
    """
    name = models.CharField(max_length=255)
    primary_muscle = models.CharField(max_length=50)
    secondary_muscles = models.JSONField(default=list)
    contribution_weight = models.JSONField(default=dict)

    def __str__(self):
        return self.name


class WorkoutLog(models.Model):
    """
    SRS 4.2: WorkoutLog (entered by the user)
    Fields:
      - id: primary key
      - user_id: FK, Owner of the log
      - exercise_id: FK, Exercise selected from dropdown
      - date: date, Date of the workout
      - sets: int, Number of sets
      - reps: int, Reps per set
      - weight_kg: float, Weight used (optional/nullable)
      - note: string, Optional note (nullable)
    """
    user_id = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        db_column="user_id",
        related_name="workout_logs",
    )
    exercise_id = models.ForeignKey(
        Exercise,
        on_delete=models.CASCADE,
        db_column="exercise_id",
        related_name="workout_logs",
    )
    date = models.DateField()
    sets = models.IntegerField()
    reps = models.IntegerField()
    weight_kg = models.FloatField(null=True, blank=True)
    note = models.TextField(null=True, blank=True)

    @property
    def user(self):
        return self.user_id

    @user.setter
    def user(self, value):
        self.user_id = value

    @property
    def exercise(self):
        return self.exercise_id

    @exercise.setter
    def exercise(self, value):
        self.exercise_id = value

    def __str__(self):
        return f"{self.date} - {self.exercise_id.name if self.exercise_id else 'Exercise'} ({self.sets}x{self.reps})"


class WeeklyGoal(models.Model):
    """
    SRS 4.3: WeeklyGoal (set by the user, optional)
    Fields:
      - id: primary key
      - user_id: FK, Owner of the goal
      - muscle_group: string, Muscle group
      - target_sets_per_week: int, Target sets per week
    """
    user_id = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        db_column="user_id",
        related_name="weekly_goals",
    )
    muscle_group = models.CharField(max_length=50)
    target_sets_per_week = models.IntegerField()

    @property
    def user(self):
        return self.user_id

    @user.setter
    def user(self, value):
        self.user_id = value

    def __str__(self):
        return f"{self.user_id} - {self.muscle_group} ({self.target_sets_per_week} sets/week)"
