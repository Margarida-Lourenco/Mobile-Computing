import 'package:flutter/material.dart';
import '../models/opportunity.dart';

final sampleOpportunities = <Opportunity>[
  Opportunity(
    id: '1',
    startsAt: DateTime.now().add(const Duration(hours: 1)),
    endsAt: DateTime.now().add(const Duration(hours: 4)),
    latitude: 57.7068,
    longitude: 11.9673,
    organization: 'Stadsmissionen',
    title: 'Serve warm lunch',
    date: 'Today',
    time: '11:30–14:00',
    place: 'Drottninggatan 33',
    distance: '1.2 km',
    category: 'Community',
    spots: 3,
    icon: Icons.favorite_border_rounded,
    description:
        'Help set tables, welcome guests, and serve a warm lunch. The team will show you everything when you arrive.',
  ),
  Opportunity(
    id: '2',
    startsAt: DateTime.now().add(const Duration(days: 1)),
    endsAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
    latitude: 57.6906,
    longitude: 11.9514,
    organization: 'Slottsskogen vänner',
    title: 'Park clean-up walk',
    date: 'Tomorrow',
    time: '10:00–12:00',
    place: 'Slottsskogen',
    distance: '2.8 km',
    category: 'Outdoors',
    spots: 8,
    icon: Icons.eco_outlined,
    description:
        'Join a relaxed two-hour walk through Slottsskogen while collecting litter. Gloves, bags, and fika are provided.',
  ),
  Opportunity(
    id: '3',
    startsAt: DateTime.now().add(const Duration(days: 2)),
    endsAt: DateTime.now().add(const Duration(days: 2, hours: 2)),
    latitude: 57.6952,
    longitude: 11.9187,
    organization: 'Språkvänner GBG',
    title: 'Practice Swedish over fika',
    date: 'In 2 days',
    time: '15:00–16:30',
    place: 'Majorna library',
    distance: '3.4 km',
    category: 'Social',
    spots: 4,
    icon: Icons.people_outline_rounded,
    description:
        'Spend an easygoing afternoon chatting with new Gothenburgers. No teaching experience needed, just curiosity and kindness.',
  ),
];
