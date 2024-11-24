import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hedieaty/shared/components/form.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _mobileController;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _mobileController = TextEditingController();

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
    _usernameController.dispose();
    _mobileController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
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
                ),
                const SizedBox(height: 16),
                defaultFormField(
                  controller: _usernameController,
                  type: TextInputType.text,
                  label: 'Username',
                  hintText: 'Enter your username',
                  prefix: Icons.person,
                  suffix: null,
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                defaultFormField(
                  controller: _mobileController,
                  type: TextInputType.number,
                  label: 'Mobile Number',
                  hintText: 'Enter your mobile number',
                  prefix: Icons.phone,
                  suffix: null,
                  validate: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    final regex = RegExp(r'^(015|011|012|010)\d{8}$');
                    if (value.length != 11 || !regex.hasMatch(value)) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                defaultFormButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, '/home',
                          arguments: {
                            'userId': 1,
                          });
                    }
                  },
                  screenWidth: screenWidth,
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
