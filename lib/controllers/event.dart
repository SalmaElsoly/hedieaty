import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/shared/components/error_component.dart';

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

  Future<void> createEvent(EventModel event, BuildContext context) async {
    try {
      await _authService.loadLocalUserId();
      await _eventRepository.createEvent(event, _authService.localUserId);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while creating event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<List<EventModel>> getEvents(int userId, BuildContext context) async {
    try {
      return await _eventRepository.getEvents(userId);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while fetching events', context);
      return [];
    } catch (e) {
      showError('Error', e.toString(), context);
      return [];
    }
  }

  Future<List<EventModel>> getMyEvents(BuildContext context) async {
    try {
      final user = await _authService.currentUser;
      if (user == null) {
        showError('Error', 'User not found', context);
        return [];
      }
      await _authService.loadLocalUserId();
      return await _eventRepository.getEvents(_authService.localUserId);
    } on FirebaseException catch (e) {
      showError(
          'Database Error', e.message ?? 'A database error occurred', context);
      return [];
    } catch (e) {
      showError('Error', e.toString(), context);
      return [];
    }
  }

  Future<void> updateEvent(EventModel event, BuildContext context) async {
    try {
      await _eventRepository.updateEvent(event);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while updating event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<void> deleteEvent(EventModel event, BuildContext context) async {
    try {
      await _eventRepository.deleteEvent(event, _authService.currentUser!.uid);
    } on FirebaseException catch (e) {
      showError('Database Error',
          e.message ?? 'An error occurred while deleting event', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }
}
