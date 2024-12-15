import 'package:hedieaty/shared/database/local_db.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/event.dart';
import '../shared/database/firestore.dart';
import './sync_helper.dart';

class EventRepository {
  final FirestoreService _firestore = FirestoreService();
  final LocalDB _localDB = LocalDB();
  late SyncHelper _syncHelper = SyncHelper(_firestore, _localDB);

  Future<void> createEvent(EventModel event, int userId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception(
            "No internet connection. Cannot create event remotely.");
      }

      // If connected, add event to Firestore
      final firestoreId = await _firestore.createEvent(event);

      if (event.firestoreId == null) {
        event.firestoreId = firestoreId;
      }
      event.userId = userId;
      await _localDB.insertEvent(event);
      final user = await _localDB.getUser(userId);
      await _firestore.addEventToUser(user!.firestoreId!, event.firestoreId!);
      user.eventsCount += 1;
      await _localDB.updateUser(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getEvents(int userId) async {
    try {
      final localEvents = await _localDB.getEventsByUserId(userId);
      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      // final isConnected = connectivityResult == ConnectivityResult.none;

      if (connectivityResult != ConnectivityResult.none) {
        final user = await _localDB.getUser(userId);
        final remoteEvents =
            await _firestore.getEventsOfUser(user!.firestoreId!);

        await _syncHelper.syncEvents(userId, remoteEvents);
        final updatedLocalEvents = await _localDB.getEventsByUserId(userId);

        return updatedLocalEvents;
      } else {
        return localEvents;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception("No internet connection. Cannot update event.");
      }
      await _firestore.updateEvent(event);
      await _localDB.updateEvent(event);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(EventModel event, String userId) async {
    try {
      final checkConnectivity = await Connectivity().checkConnectivity();
      if (checkConnectivity == ConnectivityResult.none) {
        throw Exception("No internet connection. Cannot delete event.");
      }
      await _firestore.deleteEvent(event.firestoreId!, userId);
      await _localDB.deleteEvent(event);

      final user = await _localDB.getUserByFirestoreId(userId);
      user?.eventsCount -= 1;
      await _localDB.updateUser(user!);
    } catch (e) {
      rethrow;
    }
  }
}
