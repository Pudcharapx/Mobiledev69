import 'package:flutter/foundation.dart';
import '../models/facility.dart';
import '../repositories/facility_repository.dart';

class FacilityViewModel extends ChangeNotifier {
  final FacilityRepository _repository;

  List<LaundryMachine> _machines = [];
  List<Amenity> _amenities = [];
  List<AmenityBooking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _machineFilter = 'All'; // 'All', 'Washer', 'Dryer'

  FacilityViewModel(this._repository);

  List<LaundryMachine> get machines => _machines;
  List<Amenity> get amenities => _amenities;
  List<AmenityBooking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get machineFilter => _machineFilter;

  int get availableMachineCount => _machines.where((m) => m.isAvailable).length;

  List<LaundryMachine> get filteredMachines {
    if (_machineFilter == 'Washer') {
      return _machines.where((m) => m.type == 'Washer').toList();
    }
    if (_machineFilter == 'Dryer') {
      return _machines.where((m) => m.type == 'Dryer').toList();
    }
    return _machines;
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getMachines(),
        _repository.getAmenities(),
        _repository.getBookings(),
      ]);
      _machines = results[0] as List<LaundryMachine>;
      _amenities = results[1] as List<Amenity>;
      _bookings = results[2] as List<AmenityBooking>;
    } catch (e) {
      _errorMessage = 'Failed to load facilities: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMachineFilter(String filter) {
    if (_machineFilter != filter) {
      _machineFilter = filter;
      notifyListeners();
    }
  }

  Future<bool> startMachine(String id, {int minutes = 45}) async {
    try {
      await _repository.startMachineCycle(id, minutes);
      await loadAll();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start machine: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> bookAmenity({
    required String amenityId,
    required String amenityName,
    required String slot,
    required DateTime date,
    required String roomNumber,
  }) async {
    try {
      await _repository.bookAmenity(
        amenityId: amenityId,
        amenityName: amenityName,
        slot: slot,
        date: date,
        roomNumber: roomNumber,
      );
      await loadAll();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to book amenity: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _repository.cancelBooking(bookingId);
      await loadAll();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel booking: $e';
      notifyListeners();
      return false;
    }
  }
}
