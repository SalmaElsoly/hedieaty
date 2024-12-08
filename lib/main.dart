import 'package:flutter/material.dart';
import 'package:hedieaty/models/user.dart';
import 'package:hedieaty/services/auth.dart';
import 'package:hedieaty/views/friend_gift_list_page.dart';
import 'package:hedieaty/views/pledged_gift_page.dart';
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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'shared/database/local_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  MyApp({super.key});

  final AuthService _auth = AuthService();
  final LocalDB _localDb = LocalDB();

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
        '/my_event_list': (context) => EventListPage(),
        '/event_create': (context) => const EventCreatePage(),
        '/my_gift_list': (context) => const GiftListPage(),
        '/my_pledged_gifts': (context) => const PledgedGiftPage(),
        '/gift_detail': (context) => const GiftDetailPage(),
        '/gift_create': (context) => const GiftCreatePage(),
        '/profile': (context) => const ProfilePage(),
        '/sign_in': (context) => const SignIn(),
        '/home': (context) => const HomePage(),
      },
      home: _auth.currentUser != null ? const HomePage() : const SignIn(),
    );
  }
}
