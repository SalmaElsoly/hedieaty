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

      event.firestoreId = firestoreId;
      event.userId = userId;
      await _localDB.insertEvent(event);
      final user = await _localDB.getUser(userId);
      await _firestore.addEventToUser(event.firestoreId!, user!.firestoreId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getEvents(int userId) async {
    try {
      // Fetch local events for immediate use
      final localEvents = await _localDB.getEventsByUserId(userId);

      // Check internet connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // Fetch remote events
        final user = await _localDB.getUser(userId);
        final remoteEvents =
            await _firestore.getEventsOfUser(user!.firestoreId!);

        // Synchronize local database with remote events
        //await _syncHelper.syncEvents(userId, remoteEvents);
        return remoteEvents;
      } else {
        // If offline, return local events
        return localEvents;
      }
    } catch (e) {
      rethrow;
    }
  }
}
