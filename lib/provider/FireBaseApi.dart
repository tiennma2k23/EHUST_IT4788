import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:project/provider/NotificationProvider.dart';
import 'package:project/main.dart'; // Adjust path where navigatorKey is declared
import 'package:provider/provider.dart';

// Top-level function for handling background messages
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Initialize Firebase for background tasks
  print(
      "Background message received: ${message.notification?.title}, ${message.notification?.body}");
}

class FireBaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> initNotifications() async {
    print("Initializing Firebase Messaging...");

    // Request permissions for iOS (optional for Android)
    await _firebaseMessaging.requestPermission();

    // Register background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Get and save FCM token
    await _getFcmToken();

    // Set up notification presentation for foreground
    await _setForegroundNotificationOptions();

    // Set up notification listeners
    _initNotificationListeners();
  }

  Future<void> _getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      await _secureStorage.write(key: 'fcm_token', value: token);
      print('FCM Token: $token');
    } catch (e) {
      print('Error fetching FCM token: $e');
    }
  }

  Future<void> _setForegroundNotificationOptions() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _initNotificationListeners() {
    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          "Foreground notification received: ${message.notification?.title}, ${message.notification?.body}");

      final notificationProvider = Provider.of<NotificationProvider>(
          navigatorKey.currentContext!,
          listen: false);
      // Show a toast message
      Fluttertoast.showToast(
        msg: 'You have a new notification',
        toastLength: Toast.LENGTH_LONG, // Change to LONG for a longer duration
        gravity: ToastGravity.TOP, // Position at the top of the screen
        backgroundColor: Colors.white, // Set background color to white
        textColor: Colors.black, // Set text color to black
        fontSize: 16.0, // Optional: set font size
      );
      notificationProvider.getUnreadNotificationCount();
    });

    // Handle notifications when the app is opened from a terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleMessage(message);
      }
    });

    // Handle notifications when the app is opened from the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  void _handleMessage(RemoteMessage message) {
    print(
        "Handling notification: ${message.notification?.title}, ${message.notification?.body}");

    try {
      navigatorKey.currentState?.pushNamed('/notifications');
    } catch (e) {
      print("Error navigating to NotificationsScreen: $e");
    }
  }
}
