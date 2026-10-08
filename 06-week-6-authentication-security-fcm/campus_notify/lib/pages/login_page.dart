import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).login(_email.text.trim(), _password.text);
    if (!mounted) return;
    final state = ref.read(authStateProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_friendlyError(state.error))));
    }
  }

  String _friendlyError(Object? error) => error is FormatException
      ? error.message
      : 'Sign in failed. Check your details and try again.';

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    const Icon(Icons.notifications_active_rounded, size: 54, color: Color(0xFF2457D6)),
                    const SizedBox(height: 18),
                    Text('Campus Notify', textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Sign in to see campus announcements', textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 28),
                    TextFormField(controller: _email, keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Campus email', prefixIcon: Icon(Icons.mail_outline), border: OutlineInputBorder()),
                      validator: (value) => value != null && value.contains('@') ? null : 'Enter a valid email address'),
                    const SizedBox(height: 16),
                    TextFormField(controller: _password, obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                      validator: (value) => value != null && value.length >= 6 ? null : 'Use at least 6 characters'),
                    const SizedBox(height: 22),
                    FilledButton.icon(onPressed: auth.isLoading ? null : _login,
                      icon: auth.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login),
                      label: Text(auth.isLoading ? 'Signing in…' : 'Sign in')),
                    const SizedBox(height: 12),
                    const Text('Demo login: any valid email + 6 or more characters.', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    const Text('Mock authentication · no real account is created', textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey)),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
