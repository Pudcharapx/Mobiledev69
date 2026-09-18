import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/announcement.dart';
import 'package:project/repositories/announcement_repository.dart';
import 'package:project/viewmodels/announcement_viewmodel.dart';
import 'package:project/views/announcements/announcement_screen.dart';

class FakeAnnouncementRepo implements AnnouncementRepository {
  List<Announcement> announcements;
  FakeAnnouncementRepo(this.announcements);

  @override
  Future<List<Announcement>> getAnnouncements() async => announcements;

  @override
  Future<Announcement> getDetail(int id) async => announcements.firstWhere((a) => a.id == id);

  @override
  void markAsRead(int id) {
    final a = announcements.firstWhere((e) => e.id == id);
    a.isRead = true;
  }
}

void main() {
  testWidgets('AnnouncementScreen supports search, category filtering, and mark all as read', (tester) async {
    final repo = FakeAnnouncementRepo([
      Announcement(
        id: 1,
        title: 'Water Supply Maintenance',
        summary: 'Water will be shut off for 2 hours',
        content: 'From 13:00 to 15:00',
        publishedAt: '2026-09-18T10:00:00Z',
        isRead: false,
      ),
      Announcement(
        id: 2,
        title: 'Monthly Fire Safety Inspection',
        summary: 'Emergency evacuation test',
        content: 'Please cooperate with staff',
        publishedAt: '2026-09-17T10:00:00Z',
        isRead: false,
      ),
      Announcement(
        id: 3,
        title: 'Welcome New Residents',
        summary: 'Orientation guidelines',
        content: 'Welcome to Dorm B',
        publishedAt: '2026-09-10T10:00:00Z',
        isRead: true,
      ),
    ]);

    final vm = AnnouncementViewModel(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AnnouncementViewModel>.value(
          value: vm,
          child: const AnnouncementScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and initial cards
    expect(find.text('Announcements'), findsOneWidget);
    expect(find.text('Water Supply Maintenance'), findsOneWidget);
    expect(find.text('Monthly Fire Safety Inspection'), findsOneWidget);
    expect(find.text('Welcome New Residents'), findsOneWidget);

    // Filter by Unread (2 unread announcements)
    await tester.tap(find.text('Unread'));
    await tester.pumpAndSettle();

    expect(find.text('Water Supply Maintenance'), findsOneWidget);
    expect(find.text('Monthly Fire Safety Inspection'), findsOneWidget);
    expect(find.text('Welcome New Residents'), findsNothing);

    // Search query test
    await tester.enterText(find.byType(TextField), 'Water');
    await tester.pumpAndSettle();

    expect(find.text('Water Supply Maintenance'), findsOneWidget);
    expect(find.text('Monthly Fire Safety Inspection'), findsNothing);

    // Tap Mark all as read
    expect(find.byTooltip('Mark all as read'), findsOneWidget);
    await tester.tap(find.byTooltip('Mark all as read'));
    await tester.pumpAndSettle();

    expect(find.text('All notices marked as read'), findsOneWidget);
  });
}
