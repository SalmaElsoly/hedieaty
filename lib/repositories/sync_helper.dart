import 'package:collection/collection.dart';
import 'package:hedieaty/shared/database/firestore.dart';
import 'package:hedieaty/shared/database/local_db.dart';
import 'package:hedieaty/models/user.dart';

import '../models/event.dart';
import '../models/gift.dart';

class SyncHelper {
  final FirestoreService _firestore;
  final LocalDB _localDB;

  SyncHelper(this._firestore, this._localDB);

  Future<void> syncFriends(String userId, List<UserModel> remoteFriends) async {
    final localFriends =
        await _localDB.getFriendOfUser(userId); // Local friends

    for (var remoteFriend in remoteFriends) {
      // Check if the friend exists in the local database
      final UserModel? existingFriend = localFriends.firstWhereOrNull(
        (friend) => friend.firestoreId == remoteFriend.firestoreId,
      );

      if (existingFriend != null) {
        // Friend exists, so update their information in the local database
        await _localDB.updateUser(UserModel(
          email: remoteFriend.email,
          username: remoteFriend.username,
          eventsCount: remoteFriend.eventsCount,
          id: existingFriend
              .id, // Use the local friend's ID to ensure proper update
          profileImage: remoteFriend.profileImage,
          firestoreId: remoteFriend.firestoreId,
        ));
      } else {
        // Friend does not exist, so insert the friend as a new entry
        await _localDB.insertUser(UserModel(
          email: remoteFriend.email,
          username: remoteFriend.username,
          eventsCount: remoteFriend.eventsCount,
          profileImage: remoteFriend.profileImage,
          firestoreId: remoteFriend.firestoreId,
        ));
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
    final user = await _localDB.getUser(userId);
    user?.eventsCount = remoteEvents.length;
    await _localDB.updateUser(user!);
  }

  Future<void> syncGifts(int eventId, List<GiftModel> remoteGifts) async {
    print(eventId);
    await _localDB.deleteGiftsByEventId(eventId);
    for (var remoteGift in remoteGifts) {
      remoteGift.eventId = eventId;
      await _localDB.insertGift(remoteGift);
    }
  }
}
