from django.apps import AppConfig
from django.db.models.signals import post_migrate


def load_seed_exercises(sender, **kwargs):
    from django.core.management import call_command
    try:
        call_command("loaddata", "exercises", verbosity=0)
    except Exception:
        pass


class WorkoutConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "workout"

    def ready(self):
        post_migrate.connect(load_seed_exercises, sender=self)
