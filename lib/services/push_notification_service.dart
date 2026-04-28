import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static bool _isInitialized = false;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permissions (especially important for iOS and Android 13+)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the token (for debugging/targeted notifications)
        String? token = await _firebaseMessaging.getToken();
        debugPrint('FCM Token: $token');
        
        // Setup foreground message handler
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');

          if (message.notification != null) {
            debugPrint('Message also contained a notification: ${message.notification}');
          }
        });
      }
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  static Future<void> showNotification({required int id, required String title, required String body}) async {
    // This is for local notifications. 
    // Usually combined with flutter_local_notifications if we want to show a popup manually
    // but FCM handles high-priority notifications automatically when configured.
    debugPrint('Local Notification Triggered: $title - $body');
  }

  static void listenToSupabase(String currentUserId, String role) {
    if (!_isInitialized) return;
    
    Supabase.instance.client.channel('public:notifications').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      callback: (payload) {
        final newRow = payload.newRecord;
        final isBroadcast = newRow['is_broadcast'] == true;
        final targetUserId = newRow['student_id'];
        
        if (isBroadcast) {
          showNotification(
            id: newRow['id'].hashCode,
            title: '📣 Announcement from ${newRow['from_name']}',
            body: newRow['message'] ?? '',
          );
        } else if (role == 'student' && targetUserId == currentUserId) {
          showNotification(
            id: newRow['id'].hashCode,
            title: 'Reply from ${newRow['from_name']}',
            body: newRow['message'] ?? '',
          );
        } else if (role != 'student' && targetUserId != null) {
           showNotification(
            id: newRow['id'].hashCode,
            title: 'New Inquiry from ${newRow['from_name']}',
            body: newRow['message'] ?? '',
          );
        }
      }
    ).subscribe();
  }
}
