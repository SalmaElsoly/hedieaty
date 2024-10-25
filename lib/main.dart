import 'package:flutter/material.dart';
import 'package:hedieaty/views/friend_gift_list_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared/theme.dart';
import 'views/event_creation_page.dart';
import 'views/friend_event_list_page.dart';
import 'views/gift_create_page.dart';
import 'views/home_page.dart';
import 'views/event_list_page.dart';
import 'views/gift_detail_page.dart';
import 'views/gift_list_page.dart';
import 'views/profile_page.dart';
import 'views/sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final themeData = ThemeColorData(sharedPreferences);
  await themeData.loadThemeFromSharedPref();
  runApp(
    ChangeNotifierProvider<ThemeColorData>(
      create: (BuildContext context) => themeData,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeColorData>(context, listen: false)
        .loadThemeFromSharedPref();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: Provider.of<ThemeColorData>(context).themeColor,
      themeAnimationCurve: Curves.easeInOut,
      themeAnimationDuration: const Duration(milliseconds: 200),
      routes: {
        '/friend_gift_list': (context) => const FriendGiftListPage(),
        '/friend_event_list': (context) => const FriendEventListPage(),
        '/my_event_list': (context) => const EventListPage(),
        '/event_create': (context) => const EventCreatePage(),
        '/my_gift_list': (context) => const GiftListPage(),
        '/gift_detail': (context) => const GiftDetailPage(),
        '/gift_create': (context) => const GiftCreatePage(),
        '/profile': (context) => const ProfilePage(),
        '/sign_in': (context) => const SignIn(),
        '/home': (context) => const HomePage(),
      },
      home: const SignIn(),
    );
  }
}
