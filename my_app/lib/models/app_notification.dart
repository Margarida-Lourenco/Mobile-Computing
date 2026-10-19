import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id, eventId, title, kind, actorName;
  final DateTime? createdAt;
  final bool read;
  const AppNotification({
    required this.id,
    required this.eventId,
    required this.title,
    required this.kind,
    required this.actorName,
    this.createdAt,
    this.read = false,
  });
  factory AppNotification.fromFirestore(String id, Map<String, dynamic> d) =>
      AppNotification(
        id: id,
        eventId: d['eventId'] as String? ?? '',
        title: d['title'] as String? ?? '',
        kind: d['kind'] as String? ?? '',
        actorName: d['actorName'] as String? ?? 'Someone',
        createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
        read: d['read'] == true,
      );
  String get message => switch (kind) {
        'joined' => 'You joined $title.',
        'left' => 'You left $title.',
        'signup' => '$actorName signed up for $title.',
        'withdrawal' => '$actorName left $title.',
        'cancelled' => '$title was cancelled by its host.',
        _ => title,
      };
}
