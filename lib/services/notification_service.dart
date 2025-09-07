import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  static Future<void> initialize() async {
    // Request permission for iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print('FCM Token: $token');
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received foreground message: ${message.notification?.title}');
      }
      // Handle foreground notification here
      _showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('App opened from notification: ${message.notification?.title}');
      }
      // Handle notification tap here
      _handleNotificationTap(message);
    });

    // Handle terminated app messages
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('App launched from notification: ${initialMessage.notification?.title}');
      }
      _handleNotificationTap(initialMessage);
    }
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  static void _showNotification(RemoteMessage message) {
    // In a real app, you'd show a local notification here
    // For now, just print the message
    if (kDebugMode) {
      print('Notification: ${message.notification?.title} - ${message.notification?.body}');
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    // Handle what happens when user taps notification
    if (kDebugMode) {
      print('User tapped notification: ${message.data}');
    }
    
    // You can navigate to specific screens based on message data
    String? type = message.data['type'];
    switch (type) {
      case 'service_approved':
      case 'service_rejected':
        // Navigate to submission history
        break;
      case 'service_reminder':
        // Navigate to vehicle details
        break;
    }
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Background message: ${message.notification?.title}');
  }
}