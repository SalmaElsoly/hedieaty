import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/repositories/user.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/shared/database/firestore.dart';
import 'package:hedieaty/models/user.dart';

import '../shared/components/error_component.dart';

class UserController {
  static UserController? _instance;

  static UserController get instance {
    _instance ??= UserController();
    return _instance!;
  }

  final AuthService _authService = AuthService();
  final UserRepository _userRepository = UserRepository();

  User? firebaseUser;

  UserController() {
    _init();
  }

  void _init() {
    try {
      firebaseUser = _authService.currentUser;
      _authService.authStateChanges.listen((user) {
        firebaseUser = user;
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Sign in failed', context);
    }
  }

  Future<void> signUp(
      String email, String password, String name, BuildContext context) async {
    try {
      await _authService.registerWithEmailAndPassword(email, password, name);
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Sign up failed', context);
    } on FirebaseException catch (e) {
      showError(
          'Database Error', e.message ?? 'Database operation failed', context);
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _userRepository.logoutUser();
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      showError('Sign Out Error', e.message ?? 'Sign out failed', context);
    }
  }

  Future<List<UserModel>> getFriends(BuildContext context) async {
    try {
      final friends = await _userRepository.getFriends(_authService.currentUser!.uid);
      return friends;
    } on FirebaseAuthException catch (e) {
      showError('Authentication Error', e.message ?? 'Failed to get friends',
          context);
      return [];
    } on FirebaseException catch (e) {
      showError(
          'Database Error', e.message ?? 'Database operation failed', context);
      return [];
    }
  }

  Future<UserModel?> getCurrentUser(BuildContext context) async {
    try {
      return await _userRepository.getUser(_authService.currentUser!.uid);
    } on FirebaseAuthException catch (e) {
      showError(
          'Authentication Error', e.message ?? 'Failed to get user', context);
    } on FirebaseException catch (e) {
      showError(
          'Database Error', e.message ?? 'Database operation failed', context);
    }
  }

  Future<UserModel?> getUser(String userId, BuildContext context) async {
    try {
      return await _userRepository.getUser(userId);
    } on FirebaseAuthException catch (e) {
      showError(
          'Authentication Error', e.message ?? 'Failed to get user', context);
    } on FirebaseException catch (e) {
      showError(
          'Database Error', e.message ?? 'Database operation failed', context);
    }
  }

  Future<void> addFriendByEmail(String username, BuildContext context) async {
    await _userRepository.addFriendByEmail(username, _authService.currentUser!.uid);
  }

  Future<void> addFriendByUsername(String username, BuildContext context) async {
    await _userRepository.addFriendByUsername(username, _authService.currentUser!.uid);
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
