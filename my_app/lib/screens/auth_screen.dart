import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/account_registration.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final username = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false, busy = false;
  String? error;
  @override
  void dispose() {
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (register) {
        await AccountRegistration.create(
            email.text.trim(), password.text, username.text.trim());
      } else {
        await auth.signInWithEmailAndPassword(
            email: email.text.trim(), password: password.text);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'Sign in failed.');
    } catch (e) {
      if (mounted) {
        setState(() => error =
            'Could not create your account. Check your connection and Firebase rules.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.s24),
                  child: Form(
                      key: formKey,
                      child: Column(children: [
                        const Text('Göod Together',
                            style: AppTextStyles.brandTitle),
                        const SizedBox(height: 24),
                        if (register)
                          TextFormField(
                              controller: username,
                              enabled: !busy,
                              decoration: const InputDecoration(
                                  labelText: 'Username',
                                  helperText:
                                      '3–24 letters, numbers or underscores'),
                              validator: AccountRegistration.validateUsername),
                        TextFormField(
                            validator: (v) => v == null || !v.contains('@')
                                ? 'Enter your email address.'
                                : null,
                            controller: email,
                            keyboardType: TextInputType.emailAddress,
                            decoration:
                                const InputDecoration(labelText: 'Email')),
                        TextFormField(
                            validator: (v) => v == null || v.length < 6
                                ? 'Use a password with at least 6 characters.'
                                : null,
                            controller: password,
                            obscureText: true,
                            decoration:
                                const InputDecoration(labelText: 'Password')),
                        if (error != null) Text(error!),
                        FilledButton(
                            onPressed: busy ? null : submit,
                            child: Text(busy
                                ? 'Please wait…'
                                : register
                                    ? 'Create account'
                                    : 'Sign in')),
                        TextButton(
                            onPressed: busy
                                ? null
                                : () => setState(() => register = !register),
                            child: Text(register
                                ? 'Already have an account?'
                                : 'Create an account')),
                      ]))))));
}
