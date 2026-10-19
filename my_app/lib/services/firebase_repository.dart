import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/opportunity.dart';
import '../models/app_notification.dart';
import 'member_registry.dart';
import 'supabase_images.dart';
import 'attendance_change.dart';
import '../screens/edit_info_screen.dart';

class FirebaseRepository {
  final db = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  String get uid => auth.currentUser!.uid;
  String newEventId() => db.collection('opportunities').doc().id;
  Future<void> ensureProfile() async {
    final user = auth.currentUser!;
    await MemberRegistry.ensureProfile(db, user.uid, {
      'username': user.displayName ?? user.email?.split('@').first ?? 'Member',
      'name': user.displayName ?? user.email?.split('@').first ?? 'Member',
      'location': '',
      'profileImageUrl': null,
    });
  }

  Stream<List<Opportunity>> events() =>
      db.collection('opportunities').snapshots().map(
            (s) => s.docs
                .where(
                  (d) => (d.data()['cancelled'] != true ||
                      d.data()['ownerId'] == auth.currentUser?.uid),
                )
                .map((d) => Opportunity.fromFirestore(d.id, d.data()))
                .toList()
              ..sort(
                (a, b) => (b.startsAt ?? DateTime(2000)).compareTo(
                  a.startsAt ?? DateTime(2000),
                ),
              ),
          );
  Future<void> registerMember() => MemberRegistry.registerMember(db, uid);

  Stream<int?> memberCount() => db
      .doc('communityStats/members')
      .snapshots()
      .map((snapshot) => (snapshot.data()?['accounts'] as num?)?.toInt());

  Stream<ProfileInfo> profile() => db.doc('users/$uid').snapshots().map(
        (d) => ProfileInfo(
          username: d.data()?['username'] as String? ?? '',
          name: d.data()?['name'] as String? ??
              auth.currentUser?.email?.split('@').first ??
              'Member',
          location: d.data()?['location'] as String? ?? '',
          imageUrl: d.data()?['profileImageUrl'] as String?,
        ),
      );
  Stream<Set<String>> membership(String kind) => db
      .collection('users/$uid/$kind')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());
  Future<void> setMembership(String kind, String id, bool selected) async {
    if (kind == 'joined') {
      await setAttendance(id, selected);
      return;
    }
    final ref = db.doc('users/$uid/$kind/$id');
    if (selected) {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }

  Stream<List<AppNotification>> notifications() =>
      db.collection('users/$uid/notifications').snapshots().map(
            (s) => s.docs
                .map((d) => AppNotification.fromFirestore(d.id, d.data()))
                .toList()
              ..sort(
                (a, b) => (b.createdAt ?? DateTime(2000)).compareTo(
                  a.createdAt ?? DateTime(2000),
                ),
              ),
          );
  Future<void> markNotificationRead(String id) =>
      db.doc('users/$uid/notifications/$id').update({'read': true});
  Stream<List<Map<String, dynamic>>> attendees(String id) =>
      db.collection('opportunities/$id/attendees').snapshots().map(
            (s) => s.docs.map((d) => {'uid': d.id, ...d.data()}).toList()
              ..sort(
                (a, b) => (a['username'] as String).toLowerCase().compareTo(
                      (b['username'] as String).toLowerCase(),
                    ),
              ),
          );
  Future<void> setAttendance(String id, bool joining) async {
    final actor = uid;
    final eventRef = db.doc('opportunities/$id');
    final attendeeRef = eventRef.collection('attendees').doc(actor);
    final membershipRef = db.doc('users/$actor/joined/$id');
    final profileRef = db.doc('users/$actor');
    await db.runTransaction((tx) async {
      final snapshot = await tx.get(eventRef);
      final existing = await tx.get(attendeeRef);
      final membership = await tx.get(membershipRef);
      final profile = await tx.get(profileRef);
      if (!snapshot.exists) throw StateError('This event no longer exists.');
      final event = snapshot.data()!;
      if (Opportunity.fromFirestore(id, event).hasEnded(DateTime.now())) {
        throw StateError(
          'This shift has ended. Its participation history is retained.',
        );
      }
      if (membership.exists && !existing.exists) {
        throw StateError(
          'This older sign-up needs the one-time attendance migration. See UPDATE_SETUP.md.',
        );
      }
      final change = AttendanceChange.calculate(
        capacity: (event['spots'] as num).toInt(),
        count: (event['attendeeCount'] as num?)?.toInt() ?? 0,
        revision: (event['attendanceRevision'] as num?)?.toInt() ?? 0,
        alreadyJoined: existing.exists,
        joining: joining,
        cancelled: event['cancelled'] == true,
      );
      if (!change.changed) return;
      final name = profile.data()?['username'] as String? ??
          profile.data()?['name'] as String? ??
          'Member';
      final owner = event['ownerId'] as String;
      tx.update(eventRef, {
        'attendeeCount': change.count,
        'attendanceRevision': change.revision,
        'lastActorId': actor,
        'lastAction': joining ? 'joined' : 'left',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (joining) {
        tx.set(attendeeRef, {
          'username': name,
          'joinedAt': FieldValue.serverTimestamp(),
        });
        tx.set(membershipRef, {'createdAt': FieldValue.serverTimestamp()});
      } else {
        tx.delete(attendeeRef);
        tx.delete(membershipRef);
      }
      final noticeId = '${id}_${change.revision}';
      Map<String, dynamic> notice(String kind) => {
            'eventId': id,
            'title': event['title'],
            'actorId': actor,
            'actorName': name,
            'kind': kind,
            'revision': change.revision,
            'createdAt': FieldValue.serverTimestamp(),
          };
      tx.set(
        db.doc('users/$actor/notifications/$noticeId'),
        notice(joining ? 'joined' : 'left'),
      );
      if (owner != actor) {
        tx.set(
          db.doc('users/$owner/notifications/$noticeId'),
          notice(joining ? 'signup' : 'withdrawal'),
        );
      }
    });
  }

  Future<void> _cleanupPhoto(String? reference) async {
    try {
      await SupabaseImages.instance.deleteOwned(reference);
    } catch (error) {
      /* A committed save stays successful; cleanup can be retried. */
    }
  }

  Future<void> saveProfile(ProfileInfo info) async {
    String? uploaded;
    String? oldReference;
    String? savedReference;
    try {
      if (info.selectedImage != null) {
        uploaded = await SupabaseImages.instance.upload(
          'profile-images',
          info.selectedImage!,
        );
      }
      final ref = db.doc('users/$uid');
      await db.runTransaction((tx) async {
        final snapshot = await tx.get(ref);
        oldReference = snapshot.data()?['profileImageUrl'] as String?;
        savedReference = uploaded ?? (info.removeImage ? null : oldReference);
        tx.set(
            ref,
            {
              'name': info.name,
              'location': info.location,
              'profileImageUrl': savedReference,
            },
            SetOptions(merge: true));
      });
    } catch (_) {
      if (uploaded != null) await _cleanupPhoto(uploaded);
      rethrow;
    }
    if (oldReference != savedReference) await _cleanupPhoto(oldReference);
  }

  Future<void> saveEvent(
    Opportunity event, {
    Uint8List? photo,
    bool update = false,
  }) async {
    if (event.startsAt == null ||
        event.endsAt == null ||
        !event.endsAt!.isAfter(event.startsAt!)) {
      throw StateError('Choose a start time and a later end time.');
    }
    String? uploaded;
    String? previousPhoto;
    String? savedPhoto;
    final ref = db.doc('opportunities/${event.id}');
    try {
      if (photo != null) {
        uploaded = await SupabaseImages.instance.upload('event-images', photo);
      }
      await db.runTransaction((tx) async {
        final snapshot = await tx.get(ref);
        final previous = snapshot.data();
        if (update &&
            (previous == null ||
                previous['ownerId'] != uid ||
                previous['cancelled'] == true)) {
          throw StateError('Only the host can edit an active event.');
        }
        if (!update && snapshot.exists) {
          throw StateError('This event was already published.');
        }
        final count = (previous?['attendeeCount'] as num?)?.toInt() ?? 0;
        if (event.spots < count) {
          throw StateError(
            'There are already $count volunteers. Capacity cannot be lower than that.',
          );
        }
        previousPhoto = previous?['coverImageUrl'] as String?;
        savedPhoto =
            uploaded ?? (event.removeCoverImage ? null : previousPhoto);
        final data = {
          ...event.toFirestore(),
          'ownerId': uid,
          'coverImageUrl': savedPhoto,
          'imageUrls': savedPhoto == null ? <String>[] : [savedPhoto!],
          'createdAt':
              update ? previous!['createdAt'] : FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (update) {
          tx.update(ref, data);
        } else {
          tx.set(ref, {
            ...data,
            'attendeeCount': 0,
            'attendanceRevision': 0,
            'cancelled': false,
          });
        }
      });
    } catch (_) {
      if (uploaded != null) await _cleanupPhoto(uploaded);
      rethrow;
    }
    if (previousPhoto != savedPhoto) await _cleanupPhoto(previousPhoto);
  }

  Future<void> deleteEvent(Opportunity event) async {
    if (event.ownerId != uid) {
      throw StateError('Only the host can cancel this event.');
    }
    final eventRef = db.doc('opportunities/${event.id}');
    final cancelledTitle = await db.runTransaction<String>((tx) async {
      final snapshot = await tx.get(eventRef);
      if (snapshot.data()?['ownerId'] != uid) {
        throw StateError('Only the host can cancel this event.');
      }
      tx.update(eventRef, {
        'cancelled': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return snapshot.data()!['title'] as String;
    });
    // The event stays as an audit record; it is removed from Discover, Map and commitments.
    final members = await eventRef.collection('attendees').get();
    for (int offset = 0; offset < members.docs.length; offset += 400) {
      final batch = db.batch();
      for (final member in members.docs.skip(offset).take(400)) {
        batch.set(
          db.doc('users/${member.id}/notifications/${event.id}_cancelled'),
          {
            'eventId': event.id,
            'title': cancelledTitle,
            'actorId': uid,
            'actorName': auth.currentUser?.displayName ?? 'Host',
            'kind': 'cancelled',
            'revision': 0,
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
      await batch.commit();
    }
  }
}
