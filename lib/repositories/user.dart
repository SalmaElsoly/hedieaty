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
      // Check internet connection
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        final remoteFriends = await _firestore.getFriends(userId);
        await _syncHelper.syncFriends(userId, remoteFriends);
        return await _localDB.getFriendOfUser(userId);
      }
      return localFriends;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      UserModel? user;
      user = await _localDB.getUserByFirestoreId(id);
      if (user == null) {
        return await _firestore.getUser(id);
      }
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    await _localDB.deleteAllUsers();
  }

  Future<void> addFriendByEmail(String email, String userId) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      if(!isConnected){
        throw Exception('No internet connection');
      }
      final friend = await _firestore.getUserByEmail(email);
      if (friend == null) {
        throw Exception('User not found');
      }
      await _firestore.addFriend(userId, friend.firestoreId!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFriendByUsername(String username, String userId) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      if(!isConnected){
        throw Exception('No internet connection');
      }
      final friend = await _firestore.getUserByUsername(username);
      if (friend == null) {
        throw Exception('User not found');
      }
      await _firestore.addFriend(userId, friend.firestoreId!);
    } catch (e) {
      rethrow;
    }
  }

  Stream<UserModel?> getUserStream(String userId)async* {
  final connectivityResult = await Connectivity().checkConnectivity();
  final isConnected = connectivityResult != ConnectivityResult.none;
  if(!isConnected){
    yield await _localDB.getUserByFirestoreId(userId);
  }
  yield* _firestore.getUserStream(userId);
  }

  Future<void> updateUser(UserModel user) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = connectivityResult != ConnectivityResult.none;
      if(!isConnected){
        throw Exception('No internet connection, update failed');
      }

    } catch (e) {
      rethrow;
    }
  }
}
