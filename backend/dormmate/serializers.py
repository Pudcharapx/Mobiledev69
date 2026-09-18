from rest_framework import serializers
from .models import Room, Resident, Expense, MaintenanceRequest, Announcement


class RoomSerializer(serializers.ModelSerializer):
    class Meta:
        model = Room
        fields = ['id', 'building', 'floor', 'room_number', 'room_type', 'status']


class ResidentSerializer(serializers.ModelSerializer):
    room = RoomSerializer(read_only=True)
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)
    first_name = serializers.CharField(source='user.first_name', read_only=True)
    last_name = serializers.CharField(source='user.last_name', read_only=True)

    class Meta:
        model = Resident
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'room']


class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = ['id', 'billing_month', 'electricity', 'water', 'internet', 'other', 'total', 'due_date', 'payment_status', 'created_at']
        read_only_fields = ['id', 'total', 'created_at']


class MaintenanceRequestSerializer(serializers.ModelSerializer):
    class Meta:
        model = MaintenanceRequest
        fields = ['id', 'title', 'category', 'description', 'image_url', 'status', 'created_at', 'updated_at']
        read_only_fields = ['id', 'status', 'created_at', 'updated_at']


class AnnouncementSerializer(serializers.ModelSerializer):
    class Meta:
        model = Announcement
        fields = ['id', 'title', 'summary', 'content', 'image_url', 'published_at']
        read_only_fields = ['id', 'title', 'summary', 'content', 'image_url', 'published_at']
