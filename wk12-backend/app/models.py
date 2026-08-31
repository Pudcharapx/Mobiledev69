from django.db import models

# Create your models here.
class Booking(models.Model):
    destination_name = models.CharField(max_length=100, default = "UBU")
    start_date = models.DateField()
    end_date = models.DateField()
    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return self.destination_name