import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:hedieaty/shared/components/form.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late AnimationController _animationController;
  late Animation<Offset> _animation;
  bool _isSignUp = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _mounted = true;

  final UserController _userController = UserController.instance;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 0.2),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _mounted = false;
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (_mounted) {
      setState(() {
        _isLoading = value;
      });
    }
  }

  void _toggleSignUp() {
    if (_mounted) {
      setState(() {
        _isSignUp = !_isSignUp;
      });
    }
  }

  void _togglePasswordVisibility() {
    if (_mounted) {
      setState(() {
        _isPasswordVisible = !_isPasswordVisible;
      });
    }
  }

  void _toggleConfirmPasswordVisibility() {
    if (_mounted) {
      setState(() {
        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _animation,
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'Hedieaty',
                        textStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Pacifico",
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        speed: const Duration(milliseconds: 300),
                      ),
                    ],
                    totalRepeatCount: 100,
                    pause: const Duration(milliseconds: 3000),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                    key: const ValueKey('animated_text'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  defaultFormField(
                    controller: _emailController,
                    type: TextInputType.emailAddress,
                    label: 'Email',
                    hintText: 'Enter your email',
                    prefix: Icons.email,
                    suffix: null,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(
                          r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    key: const ValueKey('email_field'),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    defaultFormField(
                      controller: _usernameController,
                      type: TextInputType.text,
                      label: 'Username',
                      hintText: 'Enter your username',
                      prefix: Icons.person,
                      suffix: null,
                      key: const ValueKey('username_field'),
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  defaultFormField(
                    controller: _passwordController,
                    type: TextInputType.visiblePassword,
                    label: 'Password',
                    hintText: 'Enter your password',
                    prefix: Icons.lock,
                    suffix: _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    isPassword: !_isPasswordVisible,
                    suffixPressed: _togglePasswordVisibility,
                    validate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    key: const ValueKey('password_field'),
                  ),
                  if (_isSignUp) ...[
                    const SizedBox(height: 16),
                    defaultFormField(
                      controller: _confirmPasswordController,
                      type: TextInputType.visiblePassword,
                      label: 'Confirm Password',
                      hintText: 'Confirm your password',
                      prefix: Icons.lock,
                      key: const ValueKey('confirm_password_field'),
                      suffix: _isConfirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      isPassword: !_isConfirmPasswordVisible,
                      suffixPressed: _toggleConfirmPasswordVisibility,
                      validate: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  defaultFormButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate() && !_isLoading) {
                        _setLoading(true);
                        try {
                          if (_isSignUp) {
                            await _userController.signUp(
                              _emailController.text,
                              _passwordController.text,
                              _usernameController.text,
                              context,
                            );
                          } else {
                            await _userController.signIn(
                              _emailController.text,
                              _passwordController.text,
                              context,
                            );
                          }
                          if (!mounted) return;
                        } finally {
                          if (!mounted) return;
                          _setLoading(false);
                        }
                      }
                    },
                    screenWidth: screenWidth,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _toggleSignUp,
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Don\'t have an account? Sign Up',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
