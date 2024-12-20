import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/main.dart';
import 'package:hedieaty/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  print(
      "Message received in background: ${message.notification?.title} - ${message.notification?.body}");
}

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
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    if (notificationsEnabled == null) {
      await prefs.setBool('notifications_enabled', true);
      notificationsEnabled = true;
    }

    if (!notificationsEnabled) {
      return;
    }

    await _messaging.requestPermission(
    );

    String? token = await _messaging.getToken();
    if (token != null) {
      await _firestore
          .collection('users')
          .doc(userId)
          .set({'fcmToken': token}, SetOptions(merge: true));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print(
          'Message received in foreground: ${message.notification?.title} - ${message.notification?.body}');
      if (await areNotificationsEnabled()) {
        showNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print(
          'Message opened from terminated state or background: ${message.notification?.title} - ${message.notification?.body}');
      if (await areNotificationsEnabled()) {
        showNotification(message);
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> setNotificationSettings({
    bool sound = true,
    bool vibration = true,
    bool alert = true,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_sound', sound);
    await prefs.setBool('notification_vibration', vibration);
    await prefs.setBool('notification_alert', alert);

    NotificationSettings settings = await _messaging.requestPermission(
      sound: sound,
      alert: alert,
      badge: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
      carPlay: false,
    );

    print('Notification settings updated: Sound: $sound, Vibration: $vibration, Alert: $alert');
    print('Authorization status: ${settings.authorizationStatus}');
  }

  Future<Map<String, bool>> getNotificationSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'sound': prefs.getBool('notification_sound') ?? true,
      'vibration': prefs.getBool('notification_vibration') ?? true,
      'alert': prefs.getBool('notification_alert') ?? true,
    };
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

  Future<bool>isSoundEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_sound') ?? true;
  }

  Future<bool>isVibrationEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_vibration') ?? true;
  }

  Future<bool>isAlertEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_alert') ?? true;
  }
  Future<bool> areNotificationsEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('notifications_enabled') ?? true;
    print('Are notifications enabled? $isEnabled');
    return isEnabled;
  }

  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc.data()))
          .toList();
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    print(
        'Displaying notification: ${message.notification?.title} - ${message.notification?.body}');
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
          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).cardColor,
                  ],
                ),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.notifications,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.notification?.title ?? 'New Notification',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message.notification?.body ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          );
        },
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0, -1);
          const end = Offset.zero;
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
  }}