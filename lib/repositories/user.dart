import 'package:hedieaty/shared/database/local_db.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user.dart';
import '../shared/database/firestore.dart';

class UserRepository {
  final FirestoreService _firestore = FirestoreService();
  final LocalDB _localDB = LocalDB();

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.createUser(user);
      await loginUser(user.firestoreId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginUser(String firestoreId)async {
    try {
      UserModel loggedIn = await _firestore.getUser(firestoreId);
      await _localDB.insertUser(loggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getFriends(String userId) async {
    try {
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        final friendsRemote = await _firestore.getFriendsOfUser(userId);
        await _localDB.deleteFriendsOfUser(userId);

        for (var friendRemote in friendsRemote) {
          await _localDB.insertUser(friendRemote);
        }


        final friendsLocal = await _localDB.getFriendOfUser(userId);
        return friendsLocal.map((friend) => UserModel.fromMap(friend)).toList();
      } else {
        final friendsLocal = await _localDB.getFriendOfUser(userId);
        return friendsLocal.map((friend) => UserModel.fromMap(friend)).toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String id) async {
      try {
        final userMap = await _localDB.getUserByFirestoreId(id);
        if (userMap != null) {
          return UserModel.fromMap(userMap);
        }
        throw Exception('No user found or saved');
      } catch (e) {
        rethrow;
      }
    }


}
