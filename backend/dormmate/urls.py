from django.urls import path
from . import views

urlpatterns = [
    path('auth/login/', views.AuthLoginView.as_view(), name='dormmate-auth-login'),
    path('profile/', views.ProfileView.as_view(), name='dormmate-profile'),
    path('rooms/me/', views.RoomMeView.as_view(), name='dormmate-room-me'),
    path('expenses/', views.ExpenseListView.as_view(), name='dormmate-expenses'),
    path('expenses/<int:pk>/', views.ExpenseDetailView.as_view(), name='dormmate-expense-detail'),
    path('maintenance/', views.MaintenanceListCreateView.as_view(), name='dormmate-maintenance'),
    path('maintenance/<int:pk>/', views.MaintenanceDetailDeleteView.as_view(), name='dormmate-maintenance-detail'),
    path('announcements/', views.AnnouncementListView.as_view(), name='dormmate-announcements'),
    path('announcements/<int:pk>/', views.AnnouncementDetailView.as_view(), name='dormmate-announcement-detail'),
    path('dashboard/', views.DashboardView.as_view(), name='dormmate-dashboard'),
]
