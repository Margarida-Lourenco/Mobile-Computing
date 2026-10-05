import 'package:flutter/material.dart';

class Opportunity {
  final int id;
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
  });
}
