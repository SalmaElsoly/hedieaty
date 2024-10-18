import 'package:flutter/material.dart';
import 'shared/theme.dart';
import 'views/home_page.dart';
import 'views/event_list_page.dart';
import 'views/gift_detail_page.dart';
import 'views/gift_list_page.dart';
import 'views/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      routes: {
        '/event_list': (context) => const EventListPage(),
        '/gift_list': (context) => const GiftListPage(),
        'gift_detail': (context) => const GiftDetailPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: const HomePage(),
    );
  }
}