import '../models/parcel.dart';

abstract class ParcelRepository {
  Future<List<Parcel>> getParcels();
  Future<void> claimParcel(String id);
}

class ParcelRepositoryImpl implements ParcelRepository {
  List<Parcel> _mockParcels = [
    Parcel(
      id: 'P01',
      trackingNumber: 'TH01928472918',
      carrier: 'Flash Express',
      recipientName: 'Somchai Prasert',
      roomNumber: 'B-204',
      arrivedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: 'Ready for Pickup',
      shelfLocation: 'Shelf A-03 (Locker)',
      pickupCode: 'PK-4921',
    ),
    Parcel(
      id: 'P02',
      trackingNumber: 'SPXTH920194820',
      carrier: 'SPX Express',
      recipientName: 'Somchai Prasert',
      roomNumber: 'B-204',
      arrivedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'Ready for Pickup',
      shelfLocation: 'Counter B (Front Desk)',
      pickupCode: 'PK-8834',
    ),
    Parcel(
      id: 'P03',
      trackingNumber: 'KERDO99281726',
      carrier: 'Kerry Express',
      recipientName: 'Somchai Prasert',
      roomNumber: 'B-204',
      arrivedAt: DateTime.now().subtract(const Duration(days: 2)),
      pickedUpAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      status: 'Claimed',
      shelfLocation: 'Counter A',
      pickupCode: 'PK-1029',
    ),
    Parcel(
      id: 'P04',
      trackingNumber: 'ED847291048TH',
      carrier: 'Thailand Post',
      recipientName: 'Somchai Prasert',
      roomNumber: 'B-204',
      arrivedAt: DateTime.now().subtract(const Duration(days: 4)),
      pickedUpAt: DateTime.now().subtract(const Duration(days: 3)),
      status: 'Claimed',
      shelfLocation: 'Shelf C-12',
      pickupCode: 'PK-7712',
    ),
  ];

  ParcelRepositoryImpl({List<Parcel>? initialParcels}) {
    if (initialParcels != null) {
      _mockParcels = List.from(initialParcels);
    }
  }

  @override
  Future<List<Parcel>> getParcels() async {
    // Simulate short network delay
    await Future.delayed(const Duration(milliseconds: 60));
    return List.unmodifiable(_mockParcels);
  }

  @override
  Future<void> claimParcel(String id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    final index = _mockParcels.indexWhere((p) => p.id == id);
    if (index != -1) {
      _mockParcels[index] = _mockParcels[index].copyWith(
        status: 'Claimed',
        pickedUpAt: DateTime.now(),
      );
    }
  }
}
