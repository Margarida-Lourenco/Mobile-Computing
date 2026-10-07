import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/opportunity.dart';
import '../screens/edit_info_screen.dart';

class FirebaseRepository {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  String get uid => auth.currentUser!.uid;
  String newEventId() => db.collection('opportunities').doc().id;
  Future<void> ensureProfile() async {
    final user = auth.currentUser!;
    final ref = db.doc('users/${user.uid}');
    await db.runTransaction((transaction) async {
      if (!(await transaction.get(ref)).exists) {
        transaction.set(ref, {
          'name': user.email?.split('@').first ?? 'Member',
          'location': '',
          'profileImageUrl': null
        });
      }
    });
  }

  Stream<List<Opportunity>> events() =>
      db.collection('opportunities').snapshots().map((s) =>
          s.docs.map((d) => Opportunity.fromFirestore(d.id, d.data())).toList()
            ..sort((a, b) => (b.startsAt ?? DateTime(2000))
                .compareTo(a.startsAt ?? DateTime(2000))));
  Stream<ProfileInfo> profile() =>
      db.doc('users/$uid').snapshots().map((d) => ProfileInfo(
          name: d.data()?['name'] as String? ??
              auth.currentUser?.email?.split('@').first ??
              'Member',
          location: d.data()?['location'] as String? ?? '',
          imageUrl: d.data()?['profileImageUrl'] as String?));
  Stream<Set<String>> membership(String kind) => db
      .collection('users/$uid/$kind')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());
  Future<void> setMembership(String kind, String id, bool selected) async {
    final ref = db.doc('users/$uid/$kind/$id');
    if (selected) {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }

  Future<String> upload(XFile image, String path) async {
    final bytes = await image.readAsBytes();
    if (bytes.length >= 5 * 1024 * 1024) {
      throw StateError('Choose an image smaller than 5 MB.');
    }
    final mime = image.mimeType ??
        (image.name.toLowerCase().endsWith('.png')
            ? 'image/png'
            : 'image/jpeg');
    if (!mime.startsWith('image/')) throw StateError('Choose an image file.');
    final ref = storage.ref(path);
    await ref.putData(bytes, SettableMetadata(contentType: mime));
    return ref.getDownloadURL();
  }

  Future<void> removeOwnedPhoto(String? url, String prefix) async {
    if (url == null) return;
    try {
      final ref = storage.refFromURL(url);
      if (ref.bucket == storage.ref().bucket &&
          ref.fullPath.startsWith(prefix)) {
        await ref.delete();
      }
    } catch (_) {
      /* A committed save remains successful; cleanup may be retried by an administrator. */
    }
  }

  Future<void> saveProfile(ProfileInfo info) async {
    final photo = info.selectedImage;
    final path = 'profile_images/$uid/${DateTime.now().microsecondsSinceEpoch}';
    String? url;
    try {
      url = photo == null ? info.imageUrl : await upload(photo, path);
      await db.doc('users/$uid').set({
        'name': info.name,
        'location': info.location,
        'profileImageUrl': url
      }, SetOptions(merge: true));
      if (photo != null) {
        await removeOwnedPhoto(info.imageUrl, 'profile_images/$uid/');
      }
    } catch (_) {
      if (photo != null) {
        try {
          await storage.ref(path).delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> saveEvent(Opportunity event, XFile? photo,
      {bool update = false}) async {
    final ref = db.doc('opportunities/${event.id}');
    final previous = update ? (await ref.get()).data() : null;
    if (update && previous?['ownerId'] != uid) {
      throw StateError('Only the owner can edit this event.');
    }
    final path =
        'event_images/$uid/${event.id}/${DateTime.now().microsecondsSinceEpoch}';
    String? url;
    try {
      url = photo == null ? event.coverImageUrl : await upload(photo, path);
      await ref.set({
        ...event.toFirestore(),
        'ownerId': uid,
        'coverImageUrl': url,
        'imageUrls': url == null ? <String>[] : [url],
        'createdAt':
            update ? previous!['createdAt'] : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp()
      });
      if (photo != null) {
        await removeOwnedPhoto(
            event.coverImageUrl, 'event_images/$uid/${event.id}/');
      }
    } catch (_) {
      if (photo != null) {
        try {
          await storage.ref(path).delete();
        } catch (_) {}
      }
      rethrow;
    }
  }

  Future<void> deleteEvent(Opportunity event) async {
    if (event.ownerId != uid) {
      throw StateError('Only the owner can delete this event.');
    }
    await db.doc('opportunities/${event.id}').delete();
    await removeOwnedPhoto(
        event.coverImageUrl, 'event_images/$uid/${event.id}/');
    // Membership references are ignored when their event no longer exists.
  }
}
