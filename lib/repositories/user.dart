import 'package:hedieaty/shared/database/local_db.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/user.dart';
import '../shared/database/firestore.dart';
import './sync_helper.dart';

class UserRepository {
  final FirestoreService _firestore = FirestoreService();
  final LocalDB _localDB = LocalDB();

  late SyncHelper _syncHelper = SyncHelper(_firestore, _localDB);

  Future<int> createUser(UserModel user) async {
    try {
      final res = await _firestore.isUsernameUnique(user.username);
      if (!res) {
        throw Exception("enter a unique username, this name is used");
      }
      await _firestore.createUser(user);
      return await loginUser(user.firestoreId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> loginUser(String firestoreId) async {
    try {
      UserModel loggedIn = await _firestore.getUser(firestoreId);
      final id = await _localDB.insertUser(loggedIn);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> getFriends(String userId) async {
    try {
      final localFriends = await _localDB.getFriendOfUser(userId);
      var friends = localFriends.map((friend) => friend).toList();
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        final remoteFriends = await _firestore.getFriendsOfUser(userId);

        await _syncHelper.syncFriends(userId, remoteFriends);

        friends = remoteFriends;
      }

      return friends;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      UserModel? user;
      Future.delayed(const Duration(seconds: 1));
      user = await _localDB.getUserByFirestoreId(id);
      if (user != null) {
        return await _firestore.getUser(id);
      }
      throw Exception('No user found or saved');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _localDB.deleteAllGifts();
      await _localDB.deleteAllEvents();
      await _localDB.deleteAllUsers();
    } catch (e) {
      rethrow;
    }
  }
}
