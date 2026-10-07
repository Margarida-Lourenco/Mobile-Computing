import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountRegistration {
  static final inProgress = ValueNotifier<bool>(false);
  static String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    return RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(username)
        ? null
        : 'Use 3–24 letters, numbers or underscores.';
  }

  static Future<void> create(
      String email, String password, String username) async {
    inProgress.value = true;
    User? created;
    try {
      final result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      created = result.user!;
      await created.updateDisplayName(username);
      await FirebaseFirestore.instance.doc('users/${created.uid}').set({
        'username': username,
        'name': username,
        'location': '',
        'profileImageUrl': null
      });
    } catch (_) {
      if (created != null) {
        try {
          await created.delete();
        } catch (_) {
          await FirebaseAuth.instance.signOut();
        }
      }
      rethrow;
    } finally {
      inProgress.value = false;
    }
  }
}
