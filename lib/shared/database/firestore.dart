import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getCollectionStream(String collectionPath) {
    return _firestore.collection(collectionPath).snapshots();
  }

  Future<User>getUser(String userId)async{
    try{
      DocumentSnapshot user = await _firestore.collection('users').doc(userId).get();
      return User.fromFirestore(user);
    }catch(e){
      rethrow;
    }
  }

  Future<List<User>> getFriendsOfUser(String userId) async {
    try {
      QuerySnapshot friends = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();
      List<String> friendIds = friends.docs.map((doc) => doc.id).toList();

      if (friendIds.isEmpty) return [];
      List<User> allFriends = [];
      for (var i = 0; i < friendIds.length; i += 10) {
        var batch = friendIds.skip(i).take(10).toList();
        QuerySnapshot friendUsers = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        allFriends.addAll(
            friendUsers.docs.map((doc) => User.fromFirestore(doc)).toList());
      }
      return allFriends;
    } catch (e) {
      return [];
    }
  }
  
}