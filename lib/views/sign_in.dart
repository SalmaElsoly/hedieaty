import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn>{
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _mobileController;

  @override
  void initState(){
    super.initState();
    _usernameController = TextEditingController();
    _mobileController = TextEditingController();
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
              children: [
                const SizedBox(height: 16),
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
                  totalRepeatCount: 5,
                  pause: const Duration(milliseconds: 3000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
                const SizedBox(height: 16),
               TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter your username',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                 controller: _usernameController,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    hintText: 'Enter your mobile number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    final regex = RegExp(r'^(015|011|012|010)\d{8}$');
                    if (value.length != 11 || !regex.hasMatch(value)) {
                      return 'Please enter a valid mobile number';
                    }
                    return null;
                  },
                  controller: _mobileController,
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size(screenWidth * 0.8, 50)),
                  ),
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