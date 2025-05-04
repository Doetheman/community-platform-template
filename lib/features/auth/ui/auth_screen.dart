import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:white_label_community_app/features/auth/state/auth_service.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isRegistering = false;
  String selectedRole = 'user';
  String errorText = '';

  Future<void> _submit() async {
    final auth = AuthService();
    try {
      if (isRegistering) {
        await auth.registerWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
          role: selectedRole,
        );
      } else {
        await auth.signInWithEmail(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      }

      if (mounted) context.go('/');
    } catch (e) {
      setState(() => errorText = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isRegistering ? 'Register' : 'Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (isRegistering) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(value: 'user', child: Text('User')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selectedRole = value);
                },
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: Text(isRegistering ? 'Register' : 'Sign In'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => isRegistering = !isRegistering),
              child: Text(
                isRegistering
                    ? 'Already have an account? Sign in'
                    : 'No account? Register here',
              ),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
