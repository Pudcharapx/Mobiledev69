from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from dormmate.models import Room, Resident, Expense, MaintenanceRequest, Announcement
from datetime import date
from decimal import Decimal


class Command(BaseCommand):
    help = 'Bootstrap DormMate seed data: rooms, residents, expenses, announcements'

    def handle(self, *args, **options):
        # Create rooms
        room_b204, _ = Room.objects.get_or_create(
            room_number='204', building='B',
            defaults={'floor': 2, 'room_type': 'Twin', 'status': 'Active'}
        )
        room_a101, _ = Room.objects.get_or_create(
            room_number='101', building='A',
            defaults={'floor': 1, 'room_type': 'Single', 'status': 'Active'}
        )
        self.stdout.write(self.style.SUCCESS('Rooms created.'))

        # Assign test user to room B-204
        test_user, _ = User.objects.get_or_create(
            username='test',
            defaults={'email': 'test@example.com', 'first_name': 'Test', 'last_name': 'User'}
        )
        test_user.set_password('1234')
        test_user.save()
        Resident.objects.get_or_create(user=test_user, defaults={'room': room_b204})

        # Assign demouser to room A-101
        demo_user, _ = User.objects.get_or_create(
            username='demouser',
            defaults={'email': 'demo@example.com', 'first_name': 'Demo', 'last_name': 'User'}
        )
        demo_user.set_password('demo12345')
        demo_user.save()
        Resident.objects.get_or_create(user=demo_user, defaults={'room': room_a101})
        self.stdout.write(self.style.SUCCESS('Residents assigned.'))

        # Expenses for B-204
        for month_data in [
            ('2026-09', Decimal('620'), Decimal('180'), Decimal('300'), Decimal('0'), date(2026, 9, 30), 'Unpaid'),
            ('2026-08', Decimal('540'), Decimal('160'), Decimal('300'), Decimal('50'), date(2026, 8, 31), 'Paid'),
            ('2026-07', Decimal('480'), Decimal('170'), Decimal('300'), Decimal('0'), date(2026, 7, 31), 'Paid'),
        ]:
            m, elec, water, inet, other, due, pstatus = month_data
            exp, _ = Expense.objects.get_or_create(
                room=room_b204, billing_month=m,
                defaults={
                    'electricity': elec, 'water': water,
                    'internet': inet, 'other': other,
                    'due_date': due, 'payment_status': pstatus
                }
            )
        self.stdout.write(self.style.SUCCESS('Expenses seeded.'))

        # Maintenance requests
        if not MaintenanceRequest.objects.filter(user=test_user).exists():
            MaintenanceRequest.objects.create(
                room=room_b204, user=test_user,
                title='Air conditioner not cooling',
                category='Air Conditioner',
                description='The AC has been running but the room is still hot.',
                status='In Progress'
            )
            MaintenanceRequest.objects.create(
                room=room_b204, user=test_user,
                title='Shower drain is clogged',
                category='Bathroom',
                description='Water does not drain properly in the shower.',
                status='Pending'
            )
        self.stdout.write(self.style.SUCCESS('Maintenance requests seeded.'))

        # Announcements
        for ann_data in [
            ('Water system maintenance', 'Scheduled water outage on 20 Sep', 'The building water system will undergo maintenance on September 20, 2026 from 9:00 AM to 12:00 PM. Please store water in advance.'),
            ('Common area schedule update', 'New gym and common room hours', 'The gym is now open from 6:00 AM to 10:00 PM daily. The common room closes at 11:00 PM on weekdays and midnight on weekends.'),
            ('Parking reminder', 'Register your vehicle before Oct 1', 'All residents with vehicles must register their vehicle plate at the office before October 1, 2026 to avoid a fine.'),
        ]:
            title, summary, content = ann_data
            Announcement.objects.get_or_create(title=title, defaults={'summary': summary, 'content': content})
        self.stdout.write(self.style.SUCCESS('Announcements seeded.'))
        self.stdout.write(self.style.SUCCESS('DormMate bootstrap complete.'))
