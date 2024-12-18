import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/main.dart';
import 'package:hedieaty/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../shared/components/notification_component.dart';


class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  //create instance
  static final NotificationService _instance = NotificationService._internal();

  // Private constructor
  NotificationService._internal();

  // Factory constructor to return the singleton instance
  factory NotificationService() {
    return _instance;
  }

  Future<void> init(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? notificationsEnabled = prefs.getBool('notifications_enabled');

    if (notificationsEnabled == null) {
      await prefs.setBool('notifications_enabled', true);
      notificationsEnabled = true;
    }

    if (!notificationsEnabled) {
      return;
    }

    await _messaging.requestPermission();

    String? token = await _messaging.getToken();
    if (token != null) {
      await _firestore.collection('users').doc(userId).set({'fcmToken': token}, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.title} - ${message.notification?.body}');
      showNotification(message);

    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from terminated state or background: ${message.notification?.title} - ${message.notification?.body}');

    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.notification?.title} - ${message.notification?.body}');
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    if (!enabled) {
      print('Notifications have been disabled.');
    } else {
      print('Notifications have been enabled.');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('notifications_enabled') ?? true;
    print('Are notifications enabled? $isEnabled');
    return isEnabled;
  }
  
  Stream<List<NotificationModel>>getNotifications(String userId){
    return _firestore.collection('notifications').where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc.data())).toList();
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    print('Displaying notification: ${message.notification?.title} - ${message.notification?.body}');
    BuildContext? context = navigatorKey.currentContext;
    if (context != null) {
      showGeneralDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        transitionDuration: Duration(milliseconds: 300),
        anchorPoint: const Offset(0, 0),
        pageBuilder: (context, animation, secondaryAnimation) {
          return Align(
            alignment: Alignment.topCenter, // Position it at the top
            child: Padding(
              padding: const EdgeInsets.only(top: 50), // Padding from the top
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: notification(message, context),
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0, -1); // Start from above the screen
          const end = Offset.zero; // End at position 0
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );
    }
  }
}
