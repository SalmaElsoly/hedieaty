import 'package:hedieaty/shared/database/firestore.dart';
import 'package:hedieaty/shared/database/local_db.dart';
import 'package:hedieaty/models/user.dart';

import '../models/event.dart';

class SyncHelper {
  final FirestoreService _firestore;
  final LocalDB _localDB;

  SyncHelper(this._firestore, this._localDB);

  Future<void> syncFriends(String userId, List<UserModel> remoteFriends) async {
    final localFriends = await _localDB.getFriendOfUser(userId);

    final localMap = {
      for (var friend in localFriends) friend.firestoreId: friend
    };

    // Determine which friends to add or update
    for (var remoteFriend in remoteFriends) {
      final localFriend = localMap[remoteFriend.firestoreId];
      if (localFriend == null) {
        // Add new friend to local DB
        await _localDB.insertUser(remoteFriend);
      } else {
        // Update friend if remote data is newer
        if (DateTime.parse(remoteFriend.lastModified.toString())
            .isAfter(DateTime.parse(localFriend.lastModified.toString()))) {
          await _localDB.updateUser(remoteFriend);
        }
      }
    }
  }

  Future<void> syncEvents(int userId, List<EventModel> remoteEvents) async {
    //delete events and save the new ones
    await _localDB.deleteEventsByUserId(userId);
    for (var remoteEvent in remoteEvents) {
      remoteEvent.userId = userId;
      await _localDB.insertEvent(remoteEvent);
    }
  }
}
