import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:good_together/models/opportunity.dart';

void main() {
  test(
    'Firestore round trip preserves coordinates, ownership, photos and date',
    () {
      final event = Opportunity(
        id: 'event-1',
        organization: 'Neighbors',
        title: 'Clean up',
        date: '7 Oct',
        time: '10:00',
        place: 'Park',
        distance: '',
        category: 'Outdoors',
        description: 'Help',
        spots: 4,
        icon: Icons.people,
        ownerId: 'owner',
        latitude: 57.7,
        longitude: 11.9,
        coverImageUrl: 'https://example.com/cover.jpg',
        imageUrls: const ['https://example.com/cover.jpg'],
        startsAt: DateTime(2026, 10, 7, 10),
      );
      final result = Opportunity.fromFirestore(event.id, event.toFirestore());
      expect(result.id, event.id);
      expect(result.ownerId, 'owner');
      expect(result.latitude, 57.7);
      expect(result.longitude, 11.9);
      expect(result.imageUrls, event.imageUrls);
      expect(result.coverImageUrl, event.coverImageUrl);
      expect(result.startsAt, event.startsAt);
    },
  );
  test('missing optional image fields remain backwards compatible', () {
    final event = Opportunity.fromFirestore('legacy', {
      'title': 'Legacy',
      'spots': 3,
      'latitude': 57,
      'longitude': 12,
    });
    expect(event.coverImageUrl, isNull);
    expect(event.imageUrls, isEmpty);
    expect(event.latitude, 57.0);
  });
}
