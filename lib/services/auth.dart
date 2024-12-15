import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../repositories/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  late int localUserId = 1;

  Future<void> _saveLocalUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('localUserId', id);
    localUserId = id;
  }

  Future<int> loadLocalUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return localUserId = prefs.getInt('localUserId') ?? 0;
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    localUserId = await _userRepository.loginUser(result.user!.uid);
    await _saveLocalUserId(localUserId);
    return result;
  }

  // register with email & password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    localUserId = await _userRepository.createUser(UserModel(
      firestoreId: result.user!.uid,
      username: username,
      email: email,
    ));
    await _saveLocalUserId(localUserId);
    // Update display name
    await result.user?.updateDisplayName(username);
    return result;
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _userRepository.logoutUser();
  }
}
