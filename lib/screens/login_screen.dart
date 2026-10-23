import 'package:flutter/material.dart';

import '../services/auth_service.dart';

/// Màn hình chào: đăng nhập Google để lưu tiến độ, hoặc học thử không cần tài khoản.
class LoginScreen extends StatefulWidget {
  final AuthService auth;
  final VoidCallback onGuest;

  const LoginScreen({super.key, required this.auth, required this.onGuest});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.auth.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Chưa đăng nhập được. Hãy thử lại.\n($e)');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Nihongo N4',
                    style: text.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Học tiếng Nhật sơ cấp N5 và N4',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  FilledButton.icon(
                    key: const ValueKey('google-sign-in'),
                    onPressed: _busy ? null : _signIn,
                    icon: const Icon(Icons.login),
                    label: Text(
                      _busy ? 'Đang đăng nhập…' : 'Đăng nhập bằng Google',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Đăng nhập để lưu tiến độ và flashcard theo tài khoản.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    key: const ValueKey('guest'),
                    onPressed: _busy ? null : widget.onGuest,
                    child: const Text('Học không cần đăng nhập'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
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
}
