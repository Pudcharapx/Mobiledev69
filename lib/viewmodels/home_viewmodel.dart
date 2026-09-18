import 'package:flutter/foundation.dart';
import '../models/room.dart';
import '../models/expense.dart';
import '../models/maintenance_request.dart';
import '../models/announcement.dart';
import '../repositories/room_repository.dart';
import '../repositories/expense_repository.dart';
import '../repositories/maintenance_repository.dart';
import '../repositories/announcement_repository.dart';
import '../repositories/auth_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final RoomRepository _roomRepo;
  final ExpenseRepository _expenseRepo;
  final MaintenanceRepository _maintenanceRepo;
  final AnnouncementRepository _announcementRepo;
  final AuthRepository _authRepo;

  bool _isLoading = false;
  String? _errorMessage;

  String? _userName;
  Room? _room;
  Expense? _latestExpense;
  int _activeMaintenanceCount = 0;
  String? _activeMaintenanceStatus;
  int _unpaidExpenseCount = 0;
  double _unpaidExpenseTotal = 0.0;
  List<Announcement> _latestAnnouncements = [];

  HomeViewModel({
    required RoomRepository roomRepository,
    required ExpenseRepository expenseRepository,
    required MaintenanceRepository maintenanceRepository,
    required AnnouncementRepository announcementRepository,
    required AuthRepository authRepository,
  })  : _roomRepo = roomRepository,
        _expenseRepo = expenseRepository,
        _maintenanceRepo = maintenanceRepository,
        _announcementRepo = announcementRepository,
        _authRepo = authRepository;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _userName ?? 'Resident';
  Room? get room => _room;
  Expense? get latestExpense => _latestExpense;
  int get activeMaintenanceCount => _activeMaintenanceCount;
  String? get activeMaintenanceStatus => _activeMaintenanceStatus;
  int get unpaidExpenseCount => _unpaidExpenseCount;
  double get unpaidExpenseTotal => _unpaidExpenseTotal;
  List<Announcement> get latestAnnouncements => _latestAnnouncements;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userName = await _authRepo.getCurrentUserName();

      final results = await Future.wait([
        _roomRepo.getMyRoom().then<dynamic>((v) => v).catchError((_) => null),
        _expenseRepo.getExpenses().then<dynamic>((v) => v).catchError((_) => <Expense>[]),
        _maintenanceRepo.getRequests().then<dynamic>((v) => v).catchError((_) => <MaintenanceRequest>[]),
        _announcementRepo.getAnnouncements().then<dynamic>((v) => v).catchError((_) => <Announcement>[]),
      ]);

      _room = results[0] as Room?;

      final expenses = results[1] as List<Expense>;
      if (expenses.isNotEmpty) {
        _latestExpense = expenses.first;
      }
      final unpaid = expenses.where((e) => !e.isPaid).toList();
      _unpaidExpenseCount = unpaid.length;
      _unpaidExpenseTotal = unpaid.fold<double>(0, (s, e) => s + e.total);

      final maintenance = results[2] as List<MaintenanceRequest>;
      final active = maintenance.where((m) => m.isActive).toList();
      _activeMaintenanceCount = active.length;
      _activeMaintenanceStatus = active.isNotEmpty ? active.first.status : null;

      final announcements = results[3] as List<Announcement>;
      _latestAnnouncements = announcements.take(3).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load dashboard data.';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadDashboard();
}
