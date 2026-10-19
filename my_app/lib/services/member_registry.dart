import 'package:cloud_firestore/cloud_firestore.dart';

/// One immutable marker per authenticated account, written with the counter.
class MemberRegistry {
  static Future<void> ensureProfile(
    FirebaseFirestore db,
    String uid,
    Map<String, dynamic> initialProfile,
  ) async {
    final profile = db.doc('users/$uid');
    await db.runTransaction((tx) async {
      if (!(await tx.get(profile)).exists) {
        tx.set(profile, initialProfile);
      }
    });
  }

  /// Statistics are synchronized after sign-in; they never gate account creation.
  static Future<void> registerMember(FirebaseFirestore db, String uid) async {
    final marker = db.doc('members/$uid');
    final stats = db.doc('communityStats/members');
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        await db.runTransaction((tx) async {
          final existingMarker = await tx.get(marker);
          final counter = await tx.get(stats);

          if (!existingMarker.exists) {
            tx.set(marker, {'createdAt': FieldValue.serverTimestamp()});
            tx.set(stats, {
              'accounts':
                  ((counter.data()?['accounts'] as num?)?.toInt() ?? 0) + 1,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        });
        return;
      } on FirebaseException catch (error) {
        // Rules can reject a racing counter commit before the SDK reports a
        // transaction conflict. Retry with a fresh snapshot, with a strict bound.
        if (attempt == 4 ||
            !['permission-denied', 'aborted', 'unavailable']
                .contains(error.code)) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
      }
    }
  }
}
