from django.conf import settings
from django.db import models


class Room(models.Model):
    """SRS 7.2 — Room information"""
    building = models.CharField(max_length=50)
    floor = models.IntegerField()
    room_number = models.CharField(max_length=20)
    room_type = models.CharField(max_length=50, default='Standard')
    status = models.CharField(max_length=20, default='Active')

    def __str__(self):
        return f"{self.building}-{self.room_number}"


class Resident(models.Model):
    """Links a Django User to a Room"""
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='resident_profile')
    room = models.ForeignKey(Room, on_delete=models.SET_NULL, null=True, blank=True, related_name='residents')

    def __str__(self):
        return f"{self.user.username} — {self.room}"


class Expense(models.Model):
    """SRS 7.3 — Monthly expense record"""
    STATUS_CHOICES = [('Unpaid', 'Unpaid'), ('Paid', 'Paid')]
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='expenses')
    billing_month = models.CharField(max_length=7)  # YYYY-MM
    electricity = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    water = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    internet = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    other = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    total = models.DecimalField(max_digits=8, decimal_places=2, default=0)
    due_date = models.DateField(null=True, blank=True)
    payment_status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='Unpaid')
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        self.total = self.electricity + self.water + self.internet + self.other
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.room} — {self.billing_month} ({self.payment_status})"


class MaintenanceRequest(models.Model):
    """SRS 7.4 — Maintenance request"""
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('In Progress', 'In Progress'),
        ('Completed', 'Completed'),
        ('Cancelled', 'Cancelled'),
    ]
    CATEGORY_CHOICES = [
        ('Electrical', 'Electrical'),
        ('Water', 'Water'),
        ('Air Conditioner', 'Air Conditioner'),
        ('Furniture', 'Furniture'),
        ('Internet', 'Internet'),
        ('Bathroom', 'Bathroom'),
        ('Cleaning', 'Cleaning'),
        ('Other', 'Other'),
    ]
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='maintenance_requests')
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='maintenance_requests')
    title = models.CharField(max_length=255)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    description = models.TextField()
    image_url = models.URLField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.title} ({self.status})"


class Announcement(models.Model):
    """SRS 7.5 — Dormitory announcement"""
    title = models.CharField(max_length=255)
    summary = models.CharField(max_length=500)
    content = models.TextField()
    image_url = models.URLField(null=True, blank=True)
    published_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.title
