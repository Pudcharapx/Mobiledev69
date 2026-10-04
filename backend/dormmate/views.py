import uuid
from datetime import timedelta
from django.utils import timezone
from django.contrib.auth import authenticate
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from django.shortcuts import get_object_or_404
from oidc_provider.models import Client, Token
from .models import Resident, Expense, MaintenanceRequest, Announcement
from .serializers import (
    ResidentSerializer,
    ExpenseSerializer,
    MaintenanceRequestSerializer,
    AnnouncementSerializer,
)


class AuthLoginView(APIView):
    """POST /api/dormmate/auth/login/ — Authenticate and issue Bearer access token."""
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(username=username, password=password)
        if not user:
            return Response({'error': 'Invalid username or password'}, status=status.HTTP_401_UNAUTHORIZED)

        client = Client.objects.filter(client_id='muscledev-frontend').first()
        token = Token.objects.filter(user=user, client=client).order_by('-expires_at').first()
        if not token:
            token = Token.objects.create(
                user=user,
                client=client,
                access_token=uuid.uuid4().hex,
                refresh_token=uuid.uuid4().hex,
                expires_at=timezone.now() + timedelta(days=30),
                _scope='openid profile email'
            )
        elif token.has_expired():
            token.access_token = uuid.uuid4().hex
            token.expires_at = timezone.now() + timedelta(days=30)
            token.save()

        return Response({
            'access_token': token.access_token,
            'token_type': 'Bearer',
            'expires_in': int((token.expires_at - timezone.now()).total_seconds()),
            'user': {
                'username': user.username,
                'email': user.email,
                'first_name': user.first_name,
                'last_name': user.last_name,
            }
        })


class ProfileView(APIView):
    """GET /api/dormmate/profile/ — Return authenticated user's resident profile."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        resident = get_object_or_404(Resident, user=request.user)
        serializer = ResidentSerializer(resident)
        return Response(serializer.data)


class RoomMeView(APIView):
    """GET /api/dormmate/rooms/me/ — Return the user's room."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        resident = get_object_or_404(Resident, user=request.user)
        from .serializers import RoomSerializer
        serializer = RoomSerializer(resident.room)
        return Response(serializer.data)


class ExpenseListView(generics.ListAPIView):
    """GET /api/dormmate/expenses/ — List all expenses for the user's room."""
    serializer_class = ExpenseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        resident = get_object_or_404(Resident, user=self.request.user)
        return Expense.objects.filter(room=resident.room).order_by('-billing_month')


class ExpenseDetailView(generics.RetrieveAPIView):
    """GET /api/dormmate/expenses/{id}/ — Detail of one expense."""
    serializer_class = ExpenseSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        resident = get_object_or_404(Resident, user=self.request.user)
        return Expense.objects.filter(room=resident.room)


class MaintenanceListCreateView(generics.ListCreateAPIView):
    """GET /api/dormmate/maintenance/ — List all requests. POST — Create new."""
    serializer_class = MaintenanceRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return MaintenanceRequest.objects.filter(
            user=self.request.user
        ).order_by('-created_at')

    def perform_create(self, serializer):
        resident = get_object_or_404(Resident, user=self.request.user)
        serializer.save(user=self.request.user, room=resident.room)


class MaintenanceDetailDeleteView(generics.RetrieveDestroyAPIView):
    """GET /api/dormmate/maintenance/{id}/ — Detail. DELETE — Delete/Cancel."""
    serializer_class = MaintenanceRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return MaintenanceRequest.objects.filter(user=self.request.user)

    def perform_destroy(self, instance):
        if instance.status in ('Pending',):
            instance.delete()
        else:
            instance.status = 'Cancelled'
            instance.save()


class AnnouncementListView(generics.ListAPIView):
    """GET /api/dormmate/announcements/ — List all announcements."""
    serializer_class = AnnouncementSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Announcement.objects.all().order_by('-published_at')


class AnnouncementDetailView(generics.RetrieveAPIView):
    """GET /api/dormmate/announcements/{id}/ — Detail of one announcement."""
    serializer_class = AnnouncementSerializer
    permission_classes = [permissions.IsAuthenticated]
    queryset = Announcement.objects.all()


class DashboardView(APIView):
    """GET /api/dormmate/dashboard/ — Aggregated dashboard data."""
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        resident = get_object_or_404(Resident, user=request.user)
        room = resident.room

        # Latest expense
        latest_expense = Expense.objects.filter(room=room).order_by('-billing_month').first()
        # Active maintenance count
        active_maintenance = MaintenanceRequest.objects.filter(
            user=request.user,
            status__in=['Pending', 'In Progress']
        ).count()
        active_maintenance_status = MaintenanceRequest.objects.filter(
            user=request.user,
            status__in=['Pending', 'In Progress']
        ).values('status').first()
        # Latest announcement
        latest_announcement = Announcement.objects.order_by('-published_at').first()

        from .serializers import RoomSerializer, AnnouncementSerializer, ExpenseSerializer
        return Response({
            'user': {
                'username': request.user.username,
                'first_name': request.user.first_name,
                'last_name': request.user.last_name,
                'email': request.user.email,
            },
            'room': RoomSerializer(room).data if room else None,
            'latest_expense': ExpenseSerializer(latest_expense).data if latest_expense else None,
            'active_maintenance_count': active_maintenance,
            'active_maintenance_status': active_maintenance_status['status'] if active_maintenance_status else None,
            'latest_announcement': AnnouncementSerializer(latest_announcement).data if latest_announcement else None,
        })
