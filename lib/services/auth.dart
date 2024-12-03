import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // auth change user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // get current user
  User? get currentUser => _auth.currentUser;

  // sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Error signing in with email and password: $e');
      return null;
    }
  }

  // register with email & password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(username);

      return result;
    } catch (e) {
      print('Error registering with email and password: $e');
      return null;
    }
  }

  // sign out
  Future<void> signOut() async {
    try {
      //TODO: sync local data with remote data
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
