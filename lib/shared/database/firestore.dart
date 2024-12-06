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
  Future<List<String>>getEventsIdsOfUser(String userId) async {
    try {
      QuerySnapshot userEventIdsSnapshot = await _firestore
          .collection('users').doc(userId).collection('events')
          .get();
      return userEventIdsSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<EventModel>> getEventsOfUser(String userId) async {
    try {
      List<String> eventIds = await getEventsIdsOfUser(userId);
      QuerySnapshot eventDetailsSnapshot = await _firestore
          .collection('events')
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      return eventDetailsSnapshot.docs
          .map((doc) => EventModel.fromFirestore(doc))
          .toList();

    } catch (e) {
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
     }
     catch (e) {
       rethrow;
     }
   }

  Future<List<GiftModel>> getGiftsByEventId(String eventId) async {
    try {
      List<String> giftIds = await getGiftsIdsByEventId(eventId);
      QuerySnapshot giftDetailsSnapshot = await _firestore.collection('gifts')
          .where(FieldPath.documentId, whereIn: giftIds)
          .get();

      return giftDetailsSnapshot.docs.map((doc) => GiftModel.fromFirestore(doc))
          .toList();
    } catch(e){
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
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
  Future<void> createEvent(EventModel event) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.firestoreId)
          .set(event.toFirestore());
    } catch (e) {
      rethrow;
    }
  }
  Future<void> createGift(GiftModel gift) async {
    try {
      await _firestore
          .collection('gifts')
          .doc(gift.firestoreId)
          .set(gift.toFirestore());
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
          .update(gift.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addGiftToEvent(String eventId, GiftModel gift) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(gift.firestoreId).set(gift.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeGiftFromEvent(String eventId, String giftId) async {
    try {
      await _firestore
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }



}
