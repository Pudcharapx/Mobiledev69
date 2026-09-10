from django.core.management import call_command
from django.db import migrations


def load_seed_exercises(apps, schema_editor):
    call_command("loaddata", "exercises", verbosity=0)


def reverse_seed_exercises(apps, schema_editor):
    Exercise = apps.get_model("workout", "Exercise")
    Exercise.objects.filter(pk__lte=18).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("workout", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(load_seed_exercises, reverse_code=reverse_seed_exercises),
    ]
