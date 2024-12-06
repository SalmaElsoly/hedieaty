import 'package:hedieaty/services/auth.dart';

import '../models/event.dart';
import '../repositories/event.dart';

class EventController {
  final EventRepository _eventRepository = EventRepository();
  final AuthService _authService = AuthService();

  static EventController? _instance;
  static EventController get instance {
    _instance ??= EventController();
    return _instance!;
  }

  Future<void> createEvent(EventModel event) async {
    try {
      await _eventRepository.createEvent(event, _authService.localUserId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getEvents(int userId) async {
    try {
      return await _eventRepository.getEvents(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getMyEvents() async {
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        throw Exception("User not found");
      }
      return await _eventRepository.getEvents(_authService.localUserId);
    } catch (e) {
      rethrow;
    }
  }
}
