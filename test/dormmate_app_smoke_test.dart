import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart';
import 'package:project/core/routing/dormmate_router.dart';
import 'package:project/repositories/auth_repository.dart';
import 'package:project/viewmodels/auth_viewmodel.dart';
import 'package:project/viewmodels/home_viewmodel.dart';
import 'package:project/viewmodels/expense_viewmodel.dart';
import 'package:project/viewmodels/maintenance_viewmodel.dart';
import 'package:project/viewmodels/announcement_viewmodel.dart';
import 'package:project/viewmodels/profile_viewmodel.dart';
import 'package:project/models/room.dart';
import 'package:project/models/user.dart';
import 'package:project/models/announcement.dart';
import 'package:provider/provider.dart';
import 'fake_repositories/fake_maintenance_repository.dart';
import 'fake_repositories/fake_expense_repository.dart';
import 'package:project/repositories/room_repository.dart';
import 'package:project/repositories/announcement_repository.dart';
import 'package:project/repositories/profile_repository.dart';

class FakeAuthRepo implements AuthRepository {
  bool loggedIn = true;
  @override
  Future<bool> login(String username, String password) async => true;
  @override
  Future<void> startOidcLogin() async {}
  @override
  Future<bool> handleOidcCallback() async => true;
  @override
  Future<void> logout() async => loggedIn = false;
  @override
  Future<bool> isAuthenticated() async => loggedIn;
  @override
  Future<String?> getCurrentUserName() async => 'Test User';
  @override
  Future<String?> getCurrentUserEmail() async => 'test@example.com';
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

class FakeProfRepo implements ProfileRepository {
  @override
  Future<User> getProfile() async => const User(
        id: 1,
        username: 'test',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
      );
}

void main() {
  testWidgets('DormMateApp mounts and displays HomeScreen when authenticated', (tester) async {
    final authRepo = FakeAuthRepo();
    final authVm = AuthViewModel(authRepo);
    await authVm.checkAuthStatus();

    final homeVm = HomeViewModel(
      roomRepository: FakeRoomRepo(),
      expenseRepository: FakeExpenseRepository(),
      maintenanceRepository: FakeMaintenanceRepository(),
      announcementRepository: FakeAnnRepo() as dynamic,
      authRepository: authRepo,
    );

    final router = createDormMateRouter(authVm);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authVm),
          ChangeNotifierProvider.value(value: homeVm),
          ChangeNotifierProvider.value(value: ExpenseViewModel(FakeExpenseRepository())),
          ChangeNotifierProvider.value(value: MaintenanceViewModel(FakeMaintenanceRepository())),
          ChangeNotifierProvider.value(value: AnnouncementViewModel(FakeAnnRepo() as dynamic)),
          ChangeNotifierProvider.value(value: ProfileViewModel(profileRepository: FakeProfRepo(), authRepository: authRepo)),
        ],
        child: DormMateApp(router: router),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('Good '), findsOneWidget);
    expect(find.text('MY ROOM'), findsOneWidget);
  });
}
