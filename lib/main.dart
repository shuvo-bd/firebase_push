import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseEnabled = false;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.initialize();
    firebaseEnabled = true;
  } catch (error) {
    debugPrint('Firebase is not configured: $error');
  }
  runApp(TaskManagerApp(firebaseEnabled: firebaseEnabled));
}
