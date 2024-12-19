import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hedieaty/main.dart' as app;

String generateRandomUsername(int length) {
  const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(
          length, (index) => characters[Random().nextInt(characters.length)])
      .join();
}

String generateRandomEmail() {
  final username = generateRandomUsername(10);
  final domain = ['example.com', 'test.com', 'mail.com'][Random().nextInt(3)];
  return '$username@$domain';
}

String generateRandomPassword(int length) {
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()_+[]{}|;:,.<>?';
  return List.generate(
          length, (index) => characters[Random().nextInt(characters.length)])
      .join();
}

Future<void> pumpUntilFound(WidgetTester tester, Finder finder,
    {Duration timeout = const Duration(seconds: 30)}) async {
  final endTime = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(endTime)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw Exception('Widget not found after $timeout');
}

Future<void> goBack(WidgetTester tester) async {
final NavigatorState navigator = tester.state(find.byType(Navigator));
navigator.pop();
await tester.pump();
}


Future<void> pumpWaitingForCondition(
  WidgetTester tester,
  bool Function() condition, {
  required int timeout,
  required int pumpDuration,
  String? reason,
}) async {
  int counter = 0;
  while (!condition()) {
    await tester.pump(Duration(milliseconds: pumpDuration));
    await tester.pump(Duration(milliseconds: pumpDuration));
    counter++;
    expect(counter, lessThanOrEqualTo(timeout ~/ pumpDuration),
        reason: reason ?? 'Timed out waiting for condition');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('End-to-end tests', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      await Firebase.initializeApp();
    });

    String username = generateRandomUsername(6);
    String email = generateRandomEmail();
    String password = generateRandomPassword(8);

    String giftName = 'Test Gift';
    String giftPrice = '100';
    String giftDescription = 'This is a test gift';

    String eventName = 'Test Event';
    String eventDescription = 'This is a test event';
    String eventLocation = 'Test Location';

    String username2 = generateRandomUsername(6);
    String email2 = generateRandomEmail();
    String password2 = generateRandomPassword(8);


    testWidgets('Signup a new user, Create event and gift then signout', (WidgetTester tester) async {
      app.main();
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await pumpUntilFound(tester, find.byType(TextFormField).at(0));

      await tester.enterText(find.byType(TextFormField).at(0), email);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(1), username);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(2), password);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(3), password);
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.text('Create Account').first);
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.text('Sign Up'));
      await pumpUntilFound(tester, find.byIcon(Icons.search));

      expect(find.text('Hedieaty'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await pumpUntilFound(tester, find.byType(TextFormField).at(0));


      await tester.enterText(find.byType(TextFormField).at(0), eventName);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(1), eventLocation);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(2), eventDescription);
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.byType(TextFormField).at(3));
      await pumpUntilFound(tester, find.byType(DatePickerDialog));
      await tester.tap(find.text('OK'));
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.byType(TextFormField).at(4));
      await pumpUntilFound(tester, find.byType(TimePickerDialog));
      await tester.tap(find.text('OK'));
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.byType(FilledButton));
      await pumpWaitingForCondition(tester,(){return find.text('Plan Your Event').evaluate().isEmpty;} , timeout: 10000, pumpDuration:100, reason: 'Timed out waiting for condition');

      await pumpUntilFound(tester, find.text('Hedieaty'));
      expect(find.text('Hedieaty'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      await tester.tap(find.byIcon(Icons.menu));
      await pumpUntilFound(tester, find.text('My Event List'));

      await tester.pump(Duration(seconds: 10));
      await tester.tap(find.text('My Event List'));

      await pumpUntilFound(tester, find.text('${username}'));

      await tester.tap(find.text('Current'));
      await pumpUntilFound(tester, find.text('${eventName}'));

      await tester.tap(find.text('${eventName}'));
      await pumpUntilFound(tester, find.byKey(Key('addGiftButton')));
      await pumpUntilFound(tester, find.text('Pledged'));

      await tester.tap(find.byKey(Key('addGiftButton')));
      await pumpUntilFound(tester, find.text('Create Your Gift'));

      await pumpUntilFound(tester, find.byType(TextFormField).at(0));


      await tester.enterText(find.byType(TextFormField).at(0), giftName);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(1), giftPrice);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(2), giftDescription);
      await tester.pump(Duration(seconds: 5));


      await tester.tap(find.byType(FilledButton));
      await pumpUntilFound(tester, find.text('My Gift List'));

      await goBack(tester);
      await goBack(tester);
      await pumpUntilFound(tester, find.text('My Events List 🎉'));

      await goBack(tester);
      await pumpUntilFound(tester, find.text('Sign Out'));

      await tester.tap(find.text('Sign Out'));
      await pumpUntilFound(tester, find.text('Welcome Back'));

      expect(find.text('Welcome Back'), findsOneWidget);
    });
    testWidgets('Signup a new user, Add friend and pledge a gift', (WidgetTester tester) async {
      app.main();
      await tester.pump(Duration(seconds: 5));
      await tester.tap(find.text('Don\'t have an account? Sign Up'));
      await pumpUntilFound(tester, find.byType(TextFormField).at(0));
      await tester.enterText(find.byType(TextFormField).at(0), email2);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(1), username2);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(2), password2);
      await tester.pump(Duration(seconds: 5));

      await tester.enterText(find.byType(TextFormField).at(3), password2);
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.text('Create Account').first);
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.text('Sign Up'));
      await pumpUntilFound(tester, find.byIcon(Icons.search));

      await tester.tap(find.byIcon(Icons.menu));
      await pumpUntilFound(tester, find.text('Add Friend'));

      await tester.tap(find.text('Add Friend'));
      await pumpUntilFound(tester, find.text('Username'));
      
      await tester.tap(find.text('Username'));
      await pumpUntilFound(tester, find.byType(TextFormField));
      
      await tester.enterText(find.byType(TextFormField), username);
      await tester.pump(Duration(seconds: 5));
      
      await tester.tap(find.text('Add'));
      await tester.pump(Duration(seconds: 5));
      await pumpWaitingForCondition(tester, ()=>find.byType(TextFormField).evaluate().isEmpty, timeout: 10000, pumpDuration: 100);


      await goBack(tester);
      await pumpUntilFound(tester, find.byIcon(Icons.menu));
      await pumpWaitingForCondition(tester, ()=>find.text('${username2}').evaluate().isEmpty, timeout: 10000, pumpDuration: 100);
      await pumpUntilFound(tester, find.text('${username}'));

      await tester.tap(find.text('${username}'));
      await pumpUntilFound(tester, find.text('Upcoming'));
      await tester.pump(Duration(seconds: 5));
      await tester.pump(Duration(seconds: 5));



      await tester.tap(find.text('Current'));
      await pumpUntilFound(tester, find.text('${eventName}'));
      await tester.pump(Duration(seconds: 5));

      await tester.tap(find.text('${eventName}'));
      await pumpUntilFound(tester, find.text('${giftName}'));

      await tester.tap(find.text('${giftName}'));
      await pumpUntilFound(tester, find.byType(Switch));
      await pumpUntilFound(tester, find.byType(DraggableScrollableSheet));

      await tester.drag(find.byType(DraggableScrollableSheet), Offset(0,-60));
      await pumpUntilFound(tester, find.text('Pledge this gift:'));

      await tester.tap(find.byType(Switch));
      await tester.pump(Duration(seconds: 5));

      await goBack(tester);
      await pumpUntilFound(tester, find.text('${eventName}'));

      await goBack(tester);
      await pumpUntilFound(tester, find.text('${username}'));

      await goBack(tester);
      await pumpUntilFound(tester, find.byIcon(Icons.menu));
      await pumpUntilFound(tester, find.byIcon(Icons.search));


      await tester.tap(find.byIcon(Icons.menu));
      await pumpUntilFound(tester, find.text('Sign Out'));

      await tester.tap(find.text('Sign Out'));
      await pumpUntilFound(tester, find.text('Welcome Back'));

      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });
}