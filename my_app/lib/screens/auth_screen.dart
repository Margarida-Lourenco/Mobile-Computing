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
          email.text.trim(),
          password.text,
          username.text.trim(),
        );
      } else {
        await auth.signInWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'Sign in failed.');
    } on FirebaseException catch (e) {
      debugPrint('Account setup failed (${e.plugin}/${e.code}): ${e.message}');
      if (mounted) {
        setState(
          () => error =
              'Could not finish account setup (${e.code}). Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Account setup failed: $e');
      if (mounted) {
        setState(
          () => error =
              'Could not create your account. Check your connection and Firebase rules.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(register ? 'Create account' : 'Sign in'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.navy,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: SafeArea(
          child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: (constraints.maxHeight - 48)
                              .clamp(0.0, double.infinity)),
                      child: Center(
                          child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                            key: formKey,
                            child: Column(
                              key: const ValueKey('auth-form'),
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Göod Together',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.brandTitle),
                                const SizedBox(height: 24),
                                if (register) ...[
                                  TextFormField(
                                    controller: username,
                                    enabled: !busy,
                                    decoration: const InputDecoration(
                                        labelText: 'Username',
                                        helperText:
                                            '3–24 letters, numbers or underscores'),
                                    validator:
                                        AccountRegistration.validateUsername,
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                TextFormField(
                                  controller: email,
                                  enabled: !busy,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  decoration:
                                      const InputDecoration(labelText: 'Email'),
                                  validator: (v) =>
                                      v == null || !v.contains('@')
                                          ? 'Enter your email address.'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: password,
                                  enabled: !busy,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      labelText: 'Password'),
                                  validator: (v) => v == null || v.length < 6
                                      ? 'Use a password with at least 6 characters.'
                                      : null,
                                ),
                                if (error != null)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(error!,
                                          style: AppTextStyles.formError)),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: busy ? null : submit,
                                  child: Text(busy
                                      ? 'Please wait…'
                                      : register
                                          ? 'Create account'
                                          : 'Sign in'),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: busy
                                      ? null
                                      : () =>
                                          setState(() => register = !register),
                                  child: Text(register
                                      ? 'Already have an account?'
                                      : 'Create an account'),
                                ),
                              ],
                            )),
                      )),
                    ),
                  )),
        ),
      );
}
