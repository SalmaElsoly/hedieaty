import 'package:flutter/material.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/views/home_page.dart';
import 'package:hedieaty/views/sign_in.dart';

class AuthStateWrapper extends StatefulWidget {
  const AuthStateWrapper({Key? key}) : super(key: key);

  @override
  State<AuthStateWrapper> createState() => _AuthStateWrapperState();
}

class _AuthStateWrapperState extends State<AuthStateWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    final AuthService authService = AuthService();
    final user = authService.currentUser;
    setState(() {
      _isAuthenticated = user != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated ? const HomePage() : const SignIn();
  }
}