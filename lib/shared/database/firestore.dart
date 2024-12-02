import 'package:cloud_firestore/cloud_firestore.dart';
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
}
