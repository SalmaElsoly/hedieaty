import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/event.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:hedieaty/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.firestoreId)
          .set(user.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String userId) async {
    try {
      DocumentSnapshot user =
          await _firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(user);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getFriendsOfUser(String userId) async {
    try {
      QuerySnapshot friends = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();
      List<String> friendIds = friends.docs.map((doc) => doc.id).toList();

      if (friendIds.isEmpty) return [];
      List<UserModel> allFriends = [];
      for (var i = 0; i < friendIds.length; i += 10) {
        var batch = friendIds.skip(i).take(10).toList();
        QuerySnapshot friendUsers = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        allFriends.addAll(friendUsers.docs
            .map((doc) => UserModel.fromFirestore(doc))
            .toList());
      }
      return allFriends;
    } catch (e) {
      return [];
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      return result.docs.isEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getEventsIdsOfUser(String userId) async {
    try {
      QuerySnapshot userEventIdsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();
      return userEventIdsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getEventsOfUser(String userId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        print('User not found for ID: $userId');
        return [];
      }

      List<dynamic> eventPaths = userSnapshot.get('events') ?? [];
      if (eventPaths.isEmpty) {
        print('No events found for user: $userId');
        return [];
      }

      List<DocumentReference> eventRefs = eventPaths.map((path) {
        return _firestore.doc(path as String);
      }).toList();

      List<DocumentSnapshot> eventSnapshots =
          await Future.wait(eventRefs.map((ref) => ref.get()));

      return eventSnapshots
          .where((snapshot) => snapshot.exists)
          .map((snapshot) => EventModel.fromFirestore(snapshot))
          .toList();
    } catch (e) {
      print('Error in getEventsOfUser: $e');
      rethrow;
    }
  }

  Future<List<String>> getGiftsIdsByEventId(String eventId) async {
    try {
      QuerySnapshot giftsSnapshot = await _firestore
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .get();
      return giftsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<GiftModel>> getGiftsByEventId(String eventId) async {
    try {
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);
      DocumentSnapshot eventSnapshot = await eventRef.get();

      if (!eventSnapshot.exists) {
        return [];
      }

      List<dynamic> giftPaths = eventSnapshot.get('gifts') ?? [];
      if (giftPaths.isEmpty) {
        return [];
      }

      List<DocumentReference> giftRefs = giftPaths.map((path) {
        return FirebaseFirestore.instance.doc(path as String);
      }).toList();

      List<DocumentSnapshot> giftSnapshots =
          await Future.wait(giftRefs.map((ref) => ref.get()));

      return giftSnapshots
          .where((snapshot) => snapshot.exists)
          .map((snapshot) => GiftModel.fromFirestore(snapshot))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId, String userId) async {
    try {
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await eventRef.delete();

      await userRef.update({
        'events': FieldValue.arrayRemove([eventRef.path]),
        'eventsCount': FieldValue.increment(-1),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGift(String giftId) async {
    try {
      await _firestore.collection('gifts').doc(giftId).delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createEvent(EventModel event) async {
    try {
      final eventReference =
          await _firestore.collection('events').add(event.toFirestore());
      return eventReference.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createGift(GiftModel gift, String userId) async {
    try {
      final giftRef =
          await _firestore.collection('gifts').add(gift.toFirestore(userId));
      return giftRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.firestoreId)
          .update(event.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGift(GiftModel gift) async {
    try {
      await _firestore
          .collection('gifts')
          .doc(gift.firestoreId)
          .update(gift.toFirestore(''));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addGiftToEvent(String eventId, GiftModel gift) async {
    try {
      DocumentReference giftRef =
          FirebaseFirestore.instance.collection('gifts').doc(gift.firestoreId);
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);

      await eventRef.update({
        'gifts': FieldValue.arrayUnion([giftRef.path]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeGiftFromEvent(String eventId, String giftId) async {
    try {
      DocumentReference giftRef =
          FirebaseFirestore.instance.collection('gifts').doc(giftId);
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);

      await eventRef.update({
        'gifts': FieldValue.arrayRemove([giftRef.path]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGiftStatus(String giftId, String newStatus) async {
    try {
      await _firestore
          .collection('gifts')
          .doc(giftId)
          .update({'status': newStatus});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addEventToUser(String userId, String eventId) async {
    try {
      DocumentReference eventRef =
          FirebaseFirestore.instance.collection('events').doc(eventId);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'events': FieldValue.arrayUnion([eventRef.path]),
        'eventsCount': FieldValue.increment(1),
      });

      print('Event $eventId successfully added to user $userId');
    } catch (e) {
      print('Error in addEventToUser: $e');
      rethrow;
    }
  }

  Stream<List<GiftModel>> getGiftsStreamForEvent(String eventId) {
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .snapshots()
        .asyncExpand((eventSnapshot) async* {
      if (!eventSnapshot.exists) {
        yield [];
        return;
      }

      // Extract the list of document references from the event document
      List<dynamic> giftPaths = eventSnapshot.get('gifts') ?? [];
      if (giftPaths.isEmpty) {
        yield [];
        return;
      }

      // Extract the document references from the paths
      List<DocumentReference> giftRefs = giftPaths.map((path) {
        return FirebaseFirestore.instance.doc(path as String);
      }).toList();

      // Listen for real-time updates for all the gift references
      yield* FirebaseFirestore.instance
          .collection('gifts')
          .where(FieldPath.documentId,
              whereIn: giftRefs.map((ref) => ref.id).toList())
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => GiftModel.fromFirestore(doc))
              .toList());
    });
  }
}
