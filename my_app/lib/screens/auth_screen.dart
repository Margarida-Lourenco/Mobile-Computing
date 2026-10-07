import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool register = false, busy = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (register) {
        await auth.createUserWithEmailAndPassword(
            email: email.text.trim(), password: password.text);
      } else {
        await auth.signInWithEmailAndPassword(
            email: email.text.trim(), password: password.text);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.message ?? 'Sign in failed.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    const Text('Göod Together',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 24),
                    TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email')),
                    TextField(
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
                  ])))));
}
