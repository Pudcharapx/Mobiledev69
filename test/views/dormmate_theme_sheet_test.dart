import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/core/theme/dormmate_theme_presets.dart';
import 'package:project/core/theme/dormmate_theme_service.dart';
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
  testWidgets('Theme selection sheet and Dark Mode toggle work interactively', (tester) async {
    final profileRepo = FakeProfileRepo();
    final authRepo = FakeAuthRepo();
    final profileVm = ProfileViewModel(profileRepository: profileRepo, authRepository: authRepo);
    final authVm = AuthViewModel(authRepo);
    final themeService = DormMateThemeService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DormMateThemeService>.value(value: themeService),
          ChangeNotifierProvider<ProfileViewModel>.value(value: profileVm),
          ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Appearance row is visible
    expect(find.text('Appearance'), findsOneWidget);

    // Verify Dark Mode switch row is visible
    expect(find.text('Dark Mode (โหมดมืด)'), findsOneWidget);

    // Tap Appearance row
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    // Verify theme options are visible
    expect(find.text('Appearance & Theme'), findsOneWidget);
    expect(find.text('Light Glassmorphic'), findsWidgets);
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('System Follow'), findsOneWidget);

    // Tap Dark Mode in sheet
    await tester.tap(find.text('Dark Mode'));
    await tester.pumpAndSettle();

    // Verify theme updated in service
    expect(themeService.preset, equals(DormMateThemePreset.dark));
    expect(themeService.isDarkMode, isTrue);

    // Tap Dark Mode switch to toggle back to Light mode
    final darkSwitch = find.descendant(
      of: find.byType(ProfileScreen),
      matching: find.byType(Switch),
    ).first;

    await tester.ensureVisible(darkSwitch);
    await tester.tap(darkSwitch);
    await tester.pumpAndSettle();

    // Verify light mode is now enabled
    expect(themeService.isDarkMode, isFalse);
    expect(themeService.preset, equals(DormMateThemePreset.light));
  });
}
