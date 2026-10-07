import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Opportunity {
  final String id;
  final String ownerId;
  final String? coverImageUrl;
  final List<String> imageUrls;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int attendeeCount;
  final bool cancelled;
  final bool removeCoverImage;
  int get spotsLeft => (spots - attendeeCount).clamp(0, spots);
  final String organization;
  final String title;
  final String date;
  final String time;
  final String place;
  final String distance;
  final String category;
  final String description;
  final int spots;
  final IconData icon;
  final double? latitude;
  final double? longitude;

  const Opportunity({
    required this.id,
    required this.organization,
    required this.title,
    required this.date,
    required this.time,
    required this.place,
    required this.distance,
    required this.category,
    required this.description,
    required this.spots,
    required this.icon,
    this.latitude,
    this.longitude,
    this.ownerId = '',
    this.coverImageUrl,
    this.imageUrls = const [],
    this.startsAt,
    this.endsAt,
    this.attendeeCount = 0,
    this.cancelled = false,
    this.removeCoverImage = false,
  });

  Map<String, dynamic> toFirestore() => {
        'organization': organization,
        'title': title,
        'date': date,
        'time': time,
        'place': place,
        'distance': distance,
        'category': category,
        'description': description,
        'spots': spots,
        'latitude': latitude,
        'longitude': longitude,
        'ownerId': ownerId,
        'coverImageUrl': coverImageUrl,
        'imageUrls': imageUrls,
        'startsAt': startsAt == null ? null : Timestamp.fromDate(startsAt!),
        'endsAt': endsAt == null ? null : Timestamp.fromDate(endsAt!),
      };
  factory Opportunity.fromFirestore(String id, Map<String, dynamic> data) {
    String text(String key) => data[key] is String ? data[key] as String : '';
    return Opportunity(
        id: id,
        organization: text('organization'),
        title: text('title'),
        date: text('date'),
        time: text('time'),
        place: text('place'),
        distance: text('distance'),
        category: text('category'),
        description: text('description'),
        spots: (data['spots'] as num?)?.toInt() ?? 0,
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        ownerId: text('ownerId'),
        coverImageUrl: data['coverImageUrl'] as String?,
        imageUrls: (data['imageUrls'] as List?)?.whereType<String>().toList() ??
            const [],
        startsAt: (data['startsAt'] as Timestamp?)?.toDate(),
        endsAt: (data['endsAt'] as Timestamp?)?.toDate(),
        attendeeCount: (data['attendeeCount'] as num?)?.toInt() ?? 0,
        cancelled: data['cancelled'] == true,
        icon: Icons.people_outline_rounded);
  }
}
