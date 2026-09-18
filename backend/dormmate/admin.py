from django.contrib import admin
from .models import Room, Resident, Expense, MaintenanceRequest, Announcement

admin.site.register(Room)
admin.site.register(Resident)
admin.site.register(Expense)
admin.site.register(MaintenanceRequest)
admin.site.register(Announcement)
