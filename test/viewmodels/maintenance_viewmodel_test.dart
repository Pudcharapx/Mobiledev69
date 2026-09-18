import 'package:flutter_test/flutter_test.dart';
import 'package:project/models/maintenance_request.dart';
import 'package:project/viewmodels/maintenance_viewmodel.dart';
import '../fake_repositories/fake_maintenance_repository.dart';

void main() {
  group('MaintenanceViewModel Unit Tests (with FakeMaintenanceRepository)', () {
    late FakeMaintenanceRepository fakeRepo;
    late MaintenanceViewModel viewModel;

    final sampleRequests = [
      const MaintenanceRequest(
        id: 1,
        title: 'Air conditioner not cooling',
        category: 'Air Conditioner',
        description: 'Room is hot',
        status: 'In Progress',
        createdAt: '2026-09-18T10:00:00Z',
        updatedAt: '2026-09-18T12:00:00Z',
      ),
      const MaintenanceRequest(
        id: 2,
        title: 'Shower drain clogged',
        category: 'Bathroom',
        description: 'Water does not drain',
        status: 'Pending',
        createdAt: '2026-09-17T09:00:00Z',
        updatedAt: '2026-09-17T09:00:00Z',
      ),
      const MaintenanceRequest(
        id: 3,
        title: 'Hallway light replaced',
        category: 'Electrical',
        description: 'Flickering bulb',
        status: 'Completed',
        createdAt: '2026-09-10T08:00:00Z',
        updatedAt: '2026-09-11T14:00:00Z',
      ),
    ];

    setUp(() {
      fakeRepo = FakeMaintenanceRepository(
        initialRequests: List.from(sampleRequests),
      );
      viewModel = MaintenanceViewModel(fakeRepo);
    });

    test('Initial state is idle with empty list before loading', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.requests, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('loadRequests successfully loads data into ViewModel state', () async {
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      await viewModel.loadRequests();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.requests.length, equals(3));
      expect(viewModel.requests.first.title, equals('Air conditioner not cooling'));
      expect(notifyCount, greaterThanOrEqualTo(2)); // loading=true then loading=false
    });

    test('loadRequests handles error state correctly', () async {
      fakeRepo.shouldThrowError = true;
      fakeRepo.errorMessage = 'Connection timed out';

      await viewModel.loadRequests();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.requests, isEmpty);
    });

    test('isEmpty returns true when there are no requests', () async {
      fakeRepo.requests.clear();

      await viewModel.loadRequests();

      expect(viewModel.isEmpty, isTrue);
      expect(viewModel.requests, isEmpty);
    });

    test('createRequest adds new item at the top and notifies listeners', () async {
      await viewModel.loadRequests();
      final initialCount = viewModel.requests.length;

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      final success = await viewModel.createRequest(
        title: 'Broken window latch',
        category: 'Furniture',
        description: 'Window cannot lock',
      );

      expect(success, isTrue);
      expect(viewModel.requests.length, equals(initialCount + 1));
      expect(viewModel.requests.first.title, equals('Broken window latch'));
      expect(viewModel.requests.first.status, equals('Pending'));
      expect(notifyCount, greaterThanOrEqualTo(2)); // submitting=true then success
    });

    test('cancelRequest removes item immediately from state and notifies listeners', () async {
      await viewModel.loadRequests();
      expect(viewModel.requests.any((r) => r.id == 2), isTrue);

      bool notified = false;
      viewModel.addListener(() => notified = true);

      final success = await viewModel.cancelRequest(2);

      expect(success, isTrue);
      expect(viewModel.requests.any((r) => r.id == 2), isFalse);
      expect(notified, isTrue);
    });

    test('filtering by status correctly filters the requests list', () async {
      await viewModel.loadRequests();

      viewModel.setFilter('Pending');
      expect(viewModel.filteredRequests.length, equals(1));
      expect(viewModel.filteredRequests.first.status, equals('Pending'));

      viewModel.setFilter('Active');
      expect(viewModel.filteredRequests.length, equals(2)); // In Progress + Pending

      viewModel.setFilter('Done');
      expect(viewModel.filteredRequests.length, equals(1)); // Completed

      viewModel.setFilter('All');
      expect(viewModel.filteredRequests.length, equals(3));
    });
  });
}
