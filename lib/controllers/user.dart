import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/repositories/user.dart';
import 'package:hedieaty/shared/database/firestore.dart';
import 'package:hedieaty/models/user.dart';

import '../shared/components/error_component.dart';

class UserController {
  static UserController? _instance;

  static UserController get instance {
    _instance ??= UserController();
    return _instance!;
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  final UserRepository _userRepository = UserRepository();


  User? firebaseUser;
  bool isLoggedIn = false;

  UserController() {
    _init();
  }

  void _init() {
    try {
      firebaseUser = _auth.currentUser;
      _auth.userChanges().listen((user) {
        firebaseUser = user;
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      final res = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _userRepository.loginUser(res.user!.uid);
      if (firebaseUser != null) {
        isLoggedIn = true;
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Sign in failed', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<void> signUp(String email, String password, String name, BuildContext context) async {
    try {
      final isUnique = await _firestore.isUsernameUnique(name);
      if (!isUnique) {
        showError('Username Error', 'Username already exists', context);
        return;
      }
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _userRepository.createUser(UserModel(
        firestoreId: result.user!.uid,
        username: name,
        email: email,
      ));
      if (firebaseUser != null) {
        isLoggedIn = true;
      }
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Sign up failed', context);
    } on FirebaseException catch (e) {
      showError(
          'Database Error', e.message ?? 'Database operation failed', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      isLoggedIn = false;
    } on FirebaseAuthException catch (e) {
      showError('Sign Out Error', e.message ?? 'Sign out failed', context);
    } catch (e) {
      showError('Error', e.toString(), context);
    }
  }

  Future<List<UserModel>> getFriends(BuildContext context) async {
    try {
      return await _userRepository.getFriends(_auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Failed to get friends', context);
      return [];
    } on FirebaseException catch (e) {
      showError('Database Error', e.message ?? 'Database operation failed', context);
      return [];
    } catch (e) {
      showError('Error', e.toString(), context);
      return [];
    }
  }

  Future<UserModel> getCurrentUser(BuildContext context) async {
    try {
      return await _userRepository.getUser(_auth.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Failed to get user', context);
      return UserModel(
        firestoreId: _auth.currentUser!.uid,
        username: _auth.currentUser?.displayName ?? 'Unknown User',
        email: _auth.currentUser?.email ?? '',
      );
    } on FirebaseException catch (e) {
      showError('Database Error', e.message ?? 'Database operation failed', context);
      return UserModel(
        firestoreId: _auth.currentUser!.uid,
        username: _auth.currentUser?.displayName ?? 'Unknown User',
        email: _auth.currentUser?.email ?? '',
      );
    } catch (e) {
      showError('Error', e.toString(), context);
      return UserModel(
        firestoreId: _auth.currentUser!.uid,
        username: _auth.currentUser?.displayName ?? 'Unknown User',
        email: _auth.currentUser?.email ?? '',
      );
    }
  }
// Future<void> updateUserProfile({String? name, String? email, BuildContext context}) async {
//   try {
//     final user = _auth.currentUser;
//     if (user != null) {
//       if (email != null) {
//         await user.updateEmail(email);
//       }
//       if (name != null) {
//         await _firestore.updateUsername(user.uid, name);
//       }
//     }
//   } on FirebaseAuthException catch (e) {
//     showError('Profile Update Error', e.message ?? 'Update failed', context);
//   } on FirebaseException catch (e) {
//     showError('Database Error', e.message ?? 'Database operation failed', context);
//   } catch (e) {
//     showError('Error', e.toString(), context);
//   }
// }
}