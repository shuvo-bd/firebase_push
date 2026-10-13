import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    required this.firebaseEnabled,
    required this.onOpenPreview,
    super.key,
  });

  final bool firebaseEnabled;
  final VoidCallback onOpenPreview;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _creatingAccount = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _brand(),
                  const SizedBox(height: 42),
                  Text(
                    'Make room for\nwhat matters.',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontSize: 34, height: 1.12),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'A little more focus, one task at a time.',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                              ? 'Use at least 6 characters'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.coral),
                    ),
                  ],
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: !widget.firebaseEnabled || _busy
                          ? null
                          : _submit,
                      child: _busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _creatingAccount ? 'Create account' : 'Sign in',
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: !widget.firebaseEnabled || _busy
                          ? null
                          : _signInWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 26),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                  Align(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _creatingAccount = !_creatingAccount;
                        _error = null;
                      }),
                      child: Text(
                        _creatingAccount
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ),
                  if (!widget.firebaseEnabled) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.tonalIcon(
                        onPressed: widget.onOpenPreview,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Open offline preview'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white),
      ),
      const SizedBox(width: 10),
      const Text(
        'daymark',
        style: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    ],
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_creatingAccount) {
        await _auth.signUp(_emailController.text, _passwordController.text);
      } else {
        await _auth.signIn(_emailController.text, _passwordController.text);
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message ?? 'Authentication failed.');
    } catch (_) {
      setState(
        () =>
            _error = 'Could not sign in. Check your connection and try again.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      setState(() => _error = error.message ?? 'Google sign-in failed.');
    } catch (_) {
      setState(() => _error = 'Google sign-in could not be completed.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
