import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:project/core/localization/language_service.dart';
import 'package:project/viewmodels/home_viewmodel.dart';
import 'package:project/models/room.dart';
import 'package:project/models/announcement.dart';
import 'package:project/repositories/room_repository.dart';
import 'package:project/repositories/announcement_repository.dart';
import 'package:project/repositories/auth_repository.dart';
import 'package:project/views/home/home_screen.dart';
import 'package:project/widgets/language_toggle_button.dart';
import '../fake_repositories/fake_expense_repository.dart';
import '../fake_repositories/fake_maintenance_repository.dart';

class MockStorage extends FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      data[key] = value;
    } else {
      data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return data[key];
  }
}

class FakeRoomRepo implements RoomRepository {
  @override
  Future<Room> getMyRoom() async => const Room(
        id: 1,
        building: 'B',
        floor: 2,
        roomNumber: '204',
        roomType: 'Twin',
        status: 'Active',
      );
}

class FakeAnnRepo implements AnnouncementRepository {
  @override
  Future<List<Announcement>> getAnnouncements() async => [];
  @override
  Future<Announcement> getDetail(int id) async => Announcement(
        id: id,
        title: 'Test',
        summary: 'Summary',
        content: 'Content',
        publishedAt: '2026-09-18',
      );
  @override
  void markAsRead(int id) {}
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
  Future<String?> getCurrentUserName() async => 'Somchai';
  @override
  Future<String?> getCurrentUserEmail() async => 'somchai@dormmate.ac.th';
}

void main() {
  testWidgets('LanguageToggleButton dynamically switches language between TH and EN', (tester) async {
    final langService = LanguageService(storage: MockStorage());
    final homeVm = HomeViewModel(
      roomRepository: FakeRoomRepo(),
      expenseRepository: FakeExpenseRepository(),
      maintenanceRepository: FakeMaintenanceRepository(),
      announcementRepository: FakeAnnRepo() as dynamic,
      authRepository: FakeAuthRepo(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LanguageService>.value(value: langService),
          ChangeNotifierProvider<HomeViewModel>.value(value: homeVm),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify LanguageToggleButton is present
    expect(find.byType(LanguageToggleButton), findsOneWidget);

    // Initial state: English
    expect(find.text('Pay Bills'), findsOneWidget);
    expect(find.text('Parcels'), findsOneWidget);
    expect(find.text('Report'), findsOneWidget);

    // Tap TH segment
    await tester.tap(find.text('TH'));
    await tester.pumpAndSettle();

    // Verify language switched to Thai
    expect(langService.isThai, isTrue);
    expect(find.text('จ่ายบิล'), findsOneWidget);
    expect(find.text('พัสดุ'), findsOneWidget);
    expect(find.text('แจ้งซ่อม'), findsWidgets);

    // Tap EN segment to switch back
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();

    // Verify language switched back to English
    expect(langService.isEnglish, isTrue);
    expect(find.text('Pay Bills'), findsOneWidget);
    expect(find.text('Parcels'), findsOneWidget);
  });

  testWidgets('Thai locale resolves MaterialLocalizations without throwing error', (tester) async {
    final langService = LanguageService(storage: MockStorage());
    await langService.setLanguage('th');

    await tester.pumpWidget(
      ChangeNotifierProvider<LanguageService>.value(
        value: langService,
        child: Consumer<LanguageService>(
          builder: (context, lang, _) => MaterialApp(
            locale: lang.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('th'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(
              builder: (context) {
                final loc = MaterialLocalizations.of(context);
                return Scaffold(
                  body: Center(
                    child: Text('OK: ${loc.okButtonLabel}'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Should find the text rendered with Thai localizations without error
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.textContaining('OK:'), findsOneWidget);
  });
}
