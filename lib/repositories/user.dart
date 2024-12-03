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

  Future<void> loginUser(String firestoreId) async {
    try {
      UserModel loggedIn = await _firestore.getUser(firestoreId);
      await _localDB.insertUser(loggedIn);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getFriends(String userId) async {
    try {
      final localFriends = await _localDB.getFriendOfUser(userId);
      var friends = localFriends.map((friend) => UserModel.fromMap(friend)).toList();

      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        final remoteFriends = await _firestore.getFriendsOfUser(userId);


        await _syncFriends(userId, remoteFriends);


        friends = remoteFriends;
      }

      return friends;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> _syncFriends(String userId, List<UserModel> remoteFriends) async {
    final localFriends = await _localDB.getFriendOfUser(userId);

    final localMap = {for (var friend in localFriends) friend['firestoreId']: friend};

    // Determine which friends to add or update
    for (var remoteFriend in remoteFriends) {
      final localFriend = localMap[remoteFriend.firestoreId];
      if (localFriend == null) {
        // Add new friend to local DB
        await _localDB.insertUser(remoteFriend);
      } else {
        // Update friend if remote data is newer
        if (DateTime.parse(remoteFriend.lastModified.toString()).isAfter(
            DateTime.parse(localFriend['lastModified']))) {
          await _localDB.updateUser(remoteFriend);
        }
      }
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
