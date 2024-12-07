import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';
import '../repositories/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  late final int localUserId;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    localUserId= await _userRepository.loginUser(result.user!.uid);
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
    // Update display name
    await result.user?.updateDisplayName(username);
    return result;
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
