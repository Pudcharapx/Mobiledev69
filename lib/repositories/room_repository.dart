import '../models/room.dart';
import '../services/api_service.dart';

abstract class RoomRepository {
  Future<Room> getMyRoom();
}

class RoomRepositoryImpl implements RoomRepository {
  final ApiService _apiService;

  RoomRepositoryImpl(this._apiService);

  @override
  Future<Room> getMyRoom() async {
    final data = await _apiService.getRoom();
    return Room.fromJson(data as Map<String, dynamic>);
  }
}
