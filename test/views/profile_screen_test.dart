import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/models/user.dart';
import 'package:project/models/room.dart';
import 'package:project/repositories/profile_repository.dart';
import 'package:project/repositories/auth_repository.dart';
import 'package:project/viewmodels/profile_viewmodel.dart';
import 'package:project/viewmodels/auth_viewmodel.dart';
import 'package:project/views/profile/profile_screen.dart';

class FakeProfileRepo implements ProfileRepository {
  @override
  Future<User> getProfile() async => const User(
        id: 1,
        username: 'somchai',
        email: 'somchai@dormmate.ac.th',
        firstName: 'Somchai',
        lastName: 'Jaidee',
        room: Room(
          id: 1,
          building: 'B',
          floor: 2,
          roomNumber: '204',
          roomType: 'Twin',
          status: 'Active',
        ),
      );
}

class FakeAuthRepo implements AuthRepository {
  @override
  Future<bool> login(String username, String password) async => true;
  @override
  Future<void> startOidcLogin() async {}
  @override
  Future<bool> handleOidcCallback() async => true;
  @override
  Future<void> logout() async {}
  @override
  Future<bool> isAuthenticated() async => true;
  @override
  Future<String?> getCurrentUserName() async => 'Somchai Jaidee';
  @override
  Future<String?> getCurrentUserEmail() async => 'somchai@dormmate.ac.th';
}

void main() {
  testWidgets('ProfileScreen setting rows open interactive sheets when tapped', (tester) async {
    final profileRepo = FakeProfileRepo();
    final authRepo = FakeAuthRepo();
    final profileVm = ProfileViewModel(profileRepository: profileRepo, authRepository: authRepo);
    final authVm = AuthViewModel(authRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ProfileViewModel>.value(value: profileVm),
          ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Pump through initial load + FadeSlideEntry delays (max delay 240ms + 450ms animation)
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Profile Info
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Somchai Jaidee'), findsOneWidget);

    // Tap 'Personal Info' row
    await tester.tap(find.text('Personal Info'));
    await tester.pumpAndSettle();

    // Verify Personal Info sheet opens
    expect(find.text('Student / Resident ID'), findsOneWidget);
    expect(find.text('STD-6510204'), findsOneWidget);

    // Close Personal Info sheet
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Tap 'Notifications' row
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    // Verify Notifications sheet opens with switches
    expect(find.text('Notification Preferences'), findsOneWidget);
    expect(find.text('Bill Due Date Reminders'), findsOneWidget);

    // Close Notifications sheet
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Scroll to ensure Appearance row is visible and hittable
    await tester.scrollUntilVisible(find.text('Appearance'), 80.0);
    await tester.pump(const Duration(milliseconds: 100));

    // Tap 'Appearance' row
    await tester.tap(find.text('Appearance'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Verify Appearance sheet opens
    expect(find.text('Appearance & Theme'), findsOneWidget);
    expect(find.text('Light Glassmorphic'), findsWidgets);
  });
}
