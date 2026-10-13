import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  bool _initialized = false;
  String? pendingTaskId;
  void Function(String? taskId)? onTaskOpened;

  Future<void> initialize() async {
    if (_initialized || kIsWeb || defaultTargetPlatform == TargetPlatform.windows) {
      return;
    }

    try {
      await FirebaseMessaging.instance.requestPermission();

      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) debugPrint('FCM token: $token');

      FirebaseMessaging.onMessage.listen((message) {
        _handleTap(message.data['taskId'] as String?);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleTap(message.data['taskId'] as String?);
      });

      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleTap(initialMessage.data['taskId'] as String?);
      }
      _initialized = true;
    } catch (error) {
      debugPrint('Notification service unavailable: $error');
    }
  }

  void _handleTap(String? taskId) {
    pendingTaskId = taskId;
    onTaskOpened?.call(taskId);
  }
}
