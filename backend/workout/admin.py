from django.contrib import admin
from .models import Exercise, WorkoutLog, WeeklyGoal


@admin.register(Exercise)
class ExerciseAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "primary_muscle")
    search_fields = ("name", "primary_muscle")


@admin.register(WorkoutLog)
class WorkoutLogAdmin(admin.ModelAdmin):
    list_display = ("id", "user_id", "exercise_id", "date", "sets", "reps", "weight_kg")
    list_filter = ("date", "exercise_id")
    search_fields = ("note",)


@admin.register(WeeklyGoal)
class WeeklyGoalAdmin(admin.ModelAdmin):
    list_display = ("id", "user_id", "muscle_group", "target_sets_per_week")
    list_filter = ("muscle_group",)
