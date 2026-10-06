// lib/services/notification_service.dart
//
// Firebase Cloud Messaging service.
// Requests permission, gets the FCM token, saves it to Firestore,
// and handles incoming messages.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  // Your VAPID key from Firebase Console (Web Push certificate)
  static const String vapidKey =
      'BP2D87Hio2fqqm3CnGrogEqg7-JGtvAsvmBz220rzp6_z0gatw6MtDx9rzZ9pSLbUanXpr2W6oIhjopEK436v70';

  // Called once at app startup to set up FCM.
  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // 1. Request permission (iOS + web)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (kDebugMode) {
        print('Notification permission denied');
      }
      return;
    }

    // 2. Get the FCM token (web needs VAPID key)
    try {
      final token = await messaging.getToken(
        vapidKey: kIsWeb ? vapidKey : null,
      );

      if (token != null) {
        await _saveTokenToFirestore(token);
        if (kDebugMode) {
          print('FCM token saved: ${token.substring(0, 20)}...');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get FCM token: $e');
      }
    }

    // 3. Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) {
      _saveTokenToFirestore(newToken);
    });

    // 4. Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message: ${message.notification?.title}');
      }
    });
  }

  // Saves the FCM token to the user's document in Firestore.
  static Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'fcmToken': token,
      'tokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Call this on logout to remove the token
  static Future<void> clearToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': FieldValue.delete(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
