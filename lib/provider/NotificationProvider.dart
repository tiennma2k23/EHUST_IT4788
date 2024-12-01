import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:project/provider/AuthProvider.dart';

class NotificationProvider with ChangeNotifier {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? token;
  int unreadCount = 0; // Store unread notification count
  final secureStorage = FlutterSecureStorage();
  final authProvider = AuthProvider();

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Fetch notifications (get_notifications API)
  Future<void> fetchNotifications({int index = 0, int count = 10}) async {
    _isLoading = true;
    notifyListeners();
    token = await secureStorage.read(key: 'token');
    print("Start get notifications");
    print("Body: " +
        json.encode(
            {"token": token, "index": index, "count": count}).toString());
    try {
      final response = await http.post(
        Uri.parse('http://160.30.168.228:8080/it5023e/get_notifications'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"token": token, "index": index, "count": count}),
      );
      print("response.statusCode: " + response.statusCode.toString());
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: " + data.toString());
        if (data['data'] != null) {
          _notifications = List<Map<String, dynamic>>.from(data['data']);
        }
      } else {
        print("Failed to fetch notifications: ${response.body}");
      }
    } catch (error) {
      print("Error fetching notifications: $error");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Mark notifications as read (mark_notification_as_read API)
  Future<void> markAsRead(List<int> notificationIds) async {
    try {
      token = await secureStorage.read(key: 'token');
      print("Start markAsRead: " +
          json.encode({
            "token": token,
            "notification_ids": notificationIds
          }).toString());
      final response = await http.post(
        Uri.parse(
            'http://160.30.168.228:8080/it5023e/mark_notification_as_read'),
        headers: {"Content-Type": "application/json"},
        body:
            json.encode({"token": token, "notification_ids": notificationIds}),
      );

      print("response.statusCode " + response.statusCode.toString());

      if (response.statusCode == 200) {
        // After successfully marking as read, reload the unread count
        await getUnreadNotificationCount();
        notifyListeners();
      } else {
        print("Failed to mark notifications as read: ${response.body}");
      }
    } catch (error) {
      print("Error marking notifications as read: $error");
    }
  }

  // Fetch unread notification count
  Future<void> getUnreadNotificationCount() async {
    token = await secureStorage.read(key: 'token');

    try {
      final response = await http.post(
        Uri.parse(
            'http://160.30.168.228:8080/it5023e/get_unread_notification_count'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"token": token}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("UnreadCountData: " + data.toString());
        unreadCount = data['data'] ?? 0;
        notifyListeners(); // Notify to update the UI
      } else {
        print("Failed to get unread notification count: ${response.body}");
      }
    } catch (error) {
      print("Error getting unread notification count: $error");
    }
  }

  // Send notification (send_notification API)
  Future<void> sendNotification({
    required String message,
    required String userName,
    required String type,
  }) async {
    token = await secureStorage.read(key: 'token');
    final results = await authProvider.searchAccount(userName);
    List<Map<String, dynamic>> searchResults = results;
    int toUser = searchResults[0]["account_id"];
    print("start send notification");
    print("Body: " +
        json.encode({
          "token": token,
          "message": message,
          "to_user": toUser,
          "type": type,
        }).toString());
    try {
      final response = await http.post(
        Uri.parse('http://160.30.168.228:8080/it5023e/send_notification'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "token": token,
          "message": message,
          "to_user": toUser,
          "type": type,
        }),
      );

      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification: ${response.body}");
      }
    } catch (error) {
      print("Error sending notification: $error");
    }
  }
}
