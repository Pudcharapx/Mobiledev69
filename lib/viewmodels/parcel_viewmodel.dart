import 'package:flutter/foundation.dart';
import '../models/parcel.dart';
import '../repositories/parcel_repository.dart';

class ParcelViewModel extends ChangeNotifier {
  final ParcelRepository _repository;

  List<Parcel> _parcels = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _activeFilter = 'All'; // 'All', 'Ready', 'Claimed'
  String _searchQuery = '';

  ParcelViewModel(this._repository);

  List<Parcel> get parcels => _parcels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get activeFilter => _activeFilter;
  String get searchQuery => _searchQuery;

  int get readyCount => _parcels.where((p) => p.isReady).length;

  List<Parcel> get filteredParcels {
    return _parcels.where((p) {
      // Filter by status
      if (_activeFilter == 'Ready' && !p.isReady) return false;
      if (_activeFilter == 'Claimed' && !p.isClaimed) return false;

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTracking = p.trackingNumber.toLowerCase().contains(query);
        final matchesCarrier = p.carrier.toLowerCase().contains(query);
        final matchesShelf = p.shelfLocation.toLowerCase().contains(query);
        return matchesTracking || matchesCarrier || matchesShelf;
      }

      return true;
    }).toList();
  }

  Future<void> loadParcels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _parcels = await _repository.getParcels();
    } catch (e) {
      _errorMessage = 'Failed to load parcels: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String filter) {
    if (_activeFilter != filter) {
      _activeFilter = filter;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> claimParcel(String id) async {
    try {
      await _repository.claimParcel(id);
      await loadParcels();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to claim parcel: $e';
      notifyListeners();
      return false;
    }
  }
}
