import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'member_registry.dart';

class AccountRegistration {
  static final inProgress = ValueNotifier<bool>(false);
  static String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    return RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(username)
        ? null
        : 'Use 3–24 letters, numbers or underscores.';
  }

  static Future<void> create(String email, String password, String username,
      {FirebaseAuth? authentication, FirebaseFirestore? database}) async {
    final auth = authentication ?? FirebaseAuth.instance;
    final db = database ?? FirebaseFirestore.instance;
    inProgress.value = true;
    User? created;
    try {
      final result = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      created = result.user!;
      await created.updateDisplayName(username);
      await MemberRegistry.ensureProfile(db, created.uid, {
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
          await auth.signOut();
        }
      }
      rethrow;
    } finally {
      inProgress.value = false;
    }
  }
}
