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

  Future<String> createGift(GiftModel gift) async {
    try {
      final giftRef =
          await _firestore.collection('gifts').add(gift.toFirestore());
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
          .update(gift.toFirestore());
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

  Future<UserModel> getUserByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if(querySnapshot.docs.isEmpty) {
        print('User not found for email: $email');
        throw Exception('User not found');
      }
      return UserModel.fromFirestore(querySnapshot.docs.first);
    }
    catch (e) {
      print('Error in getUserByEmail: $e');
      rethrow;
    }
  }

  Future<void> addFriend(String userId, String friendId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(friendId);
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'friends': FieldValue.arrayUnion([userRef.path])});
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getFriends(String userId) async {
    try {
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        print('User not found for ID: $userId');
        return [];
      }

      List<dynamic> friendsPaths = userSnapshot.get('friends') ?? [];
      if (friendsPaths.isEmpty) {
        print('No events found for user: $userId');
        return [];
      }

      List<DocumentReference> friendsRefs = friendsPaths.map((path) {
        return _firestore.doc(path as String);
      }).toList();

      List<DocumentSnapshot> friendsSnapshots =
      await Future.wait(friendsRefs.map((ref) => ref.get()));

      return friendsSnapshots
          .where((snapshot) => snapshot.exists)
          .map((snapshot) => UserModel.fromFirestore(snapshot))
          .toList();
    } catch (e) {
      print('Error in getEventsOfUser: $e');
      rethrow;
    }
  }

  Future<UserModel> getUserByUsername(String username) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      if (querySnapshot.docs.isEmpty) {
        print('User not found for username: $username');
        throw Exception('User not found');
      }
      return UserModel.fromFirestore(querySnapshot.docs.first);
    }
      catch (e) {
      print('Error in getUserByEmail: $e');
      rethrow;
    }
  }


  Future<void> deleteGiftsFromEvent(String eventId) async {

    try {

      final DocumentReference eventRef = _firestore.collection('events').doc(eventId);
      final DocumentSnapshot eventSnapshot = await eventRef.get();

      if (!eventSnapshot.exists) {
        throw Exception("Event does not exist.");
      }

      final List<dynamic> giftRefs = eventSnapshot.get('gifts') ?? [];

      if (giftRefs.isEmpty) {
        print('No gifts to delete for event: $eventId');
        return;
      }

      WriteBatch batch = _firestore.batch();

      for (var giftRef in giftRefs) {
        if (giftRef is String) {
          final DocumentReference giftDocRef = _firestore.doc(giftRef);
          batch.delete(giftDocRef);
        } else if (giftRef is DocumentReference) {
          batch.delete(giftRef);
        }
      }

      batch.update(eventRef, {'gifts': []});

      await batch.commit();

      print('Successfully deleted all gifts for event: $eventId');
    } catch (e) {
      print('Error deleting gifts from event: $e');
      rethrow;
    }
  }

  Future<List<GiftModel>> getPledgedGifts(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('gifts')
          .where('pledgedBy', isEqualTo: userId)
          .where('status', isEqualTo: 'pledged')
          .get();
      return querySnapshot.docs.map((doc) => GiftModel.fromFirestore(doc))
          .toList();
    }
      catch (e) {
      print('Error in getPledgedGifts: $e');
      rethrow;
    }
  }
}
