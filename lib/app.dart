import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/task_list_screen.dart';
import 'services/auth_service.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({required this.firebaseEnabled, super.key});

  final bool firebaseEnabled;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'daymark',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: AuthGate(firebaseEnabled: firebaseEnabled),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({required this.firebaseEnabled, super.key});

  final bool firebaseEnabled;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _auth = AuthService();
  bool _previewOpen = false;

  @override
  Widget build(BuildContext context) {
    if (_previewOpen) return _workspace(null);
    if (!widget.firebaseEnabled) {
      return AuthScreen(
        firebaseEnabled: false,
        onOpenPreview: () => setState(() => _previewOpen = true),
      );
    }

    return StreamBuilder(
      stream: _auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return AuthScreen(
            firebaseEnabled: true,
            onOpenPreview: () => setState(() => _previewOpen = true),
          );
        }
        return _workspace(user.uid);
      },
    );
  }

  Widget _workspace(String? userId) => TaskListScreen(
    key: ValueKey(userId ?? 'offline-preview'),
    userId: userId,
    firebaseEnabled: widget.firebaseEnabled,
    onSignOut: () async {
      if (userId == null) {
        setState(() => _previewOpen = false);
      } else {
        await _auth.signOut();
      }
    },
  );
}
