import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hedieaty/controllers/user.dart';
import 'package:hedieaty/views/sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import './firebase_mock.dart';

class MockUserController extends Mock implements UserController {}

void main() {
  late MockUserController mockUserController;
  setupFirebaseMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  setUp(() {
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp();
    mockUserController = MockUserController();
  });

  group('SignIn Widget Tests', () {
    testWidgets('Initial render shows SignIn form',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SignIn()));

      // Verify key elements are present
      expect(find.byKey(ValueKey('animated_text')), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byKey(ValueKey('email_field')), findsOneWidget);
      expect(find.byKey(ValueKey('password_field')), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
    });

    testWidgets('Tapping Sign Up toggles to Sign Up form',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SignIn()));

      // Tap "Don't have an account? Sign Up"
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await tester.pump();

      // Verify the Sign Up form
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byKey(ValueKey('username_field')), findsOneWidget);
      expect(find.byKey(ValueKey('confirm_password_field')), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Entering email and password triggers validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SignIn()));

      // Try submitting without entering anything
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      when(mockUserController.signIn(
        'test@example.com',
        'password123',
        tester.element(find.byType(SignIn)),
      )).thenAnswer((_) async => {});

      // Verify validation messages
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Enter valid email and password
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // No validation messages should appear
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter your password'), findsNothing);
    });

    testWidgets('Signing in shows loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SignIn()));

      // Enter email and password
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');

      // Tap Sign In
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the animation complete
      await tester.pump();
    });

    testWidgets('Toggling password visibility works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SignIn()));

      // Tap password visibility icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify password is visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap again to hide password
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify password is hidden again
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });
}
