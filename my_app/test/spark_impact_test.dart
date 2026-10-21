import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/models/community_impact.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/screens/edit_info_screen.dart';

Opportunity shift({
  DateTime? start,
  DateTime? end,
  int count = 3,
  bool cancelled = false,
}) =>
    Opportunity(
      id: 'shift',
      title: 'Help',
      organization: 'Host',
      place: '',
      date: '',
      time: '',
      distance: '',
      category: 'Community',
      description: '',
      spots: 5,
      icon: Icons.people,
      startsAt: start,
      endsAt: end,
      attendeeCount: count,
      cancelled: cancelled,
    );

void main() {
  final now = DateTime.utc(2026, 10, 14, 12);
  test('hours are computed locally from completed participant-hours', () {
    final impact = CommunityImpact.fromEvents(
      [
        shift(
          start: DateTime.utc(2026, 10, 10, 9),
          end: DateTime.utc(2026, 10, 10, 11, 30),
        ),
      ],
      12,
      now,
    );
    expect(impact.hours, 7.5);
    expect(impact.accounts, 12);
    expect(impact.month, '2026-10');
  });
  test(
    'future, cancelled, missing ends and invalid durations earn no hours',
    () {
      final start = now.subtract(const Duration(hours: 2));
      final events = [
        shift(start: start, end: now.add(const Duration(hours: 1))),
        shift(start: start, end: now, cancelled: true),
        shift(start: start),
        shift(start: now, end: start),
        shift(start: start, end: now, count: 0),
      ];
      expect(CommunityImpact.fromEvents(events, 0, now).hours, 0);
    },
  );
  test(
    'cross-month hours and Gothenburg daylight saving time are respected',
    () {
      final impact = CommunityImpact.fromEvents(
        [
          shift(
            start: DateTime.utc(2026, 9, 30, 21),
            end: DateTime.utc(2026, 10, 1, 1),
            count: 2,
          ),
        ],
        4,
        DateTime.utc(2026, 9, 30, 22, 1),
      );
      // Shift is still ongoing, even though the local month has changed.
      expect(impact.month, '2026-10');
      expect(impact.hours, 0);
      expect(
        CommunityImpact.fromEvents(
          [
            shift(
              start: DateTime.utc(2026, 9, 30, 21),
              end: DateTime.utc(2026, 10, 1, 1),
              count: 2,
            ),
          ],
          4,
          now,
        ).hours,
        6,
      );
      expect(
        CommunityImpact.fromEvents([], 0, DateTime.utc(2026, 10, 31, 23)).month,
        '2026-11',
      );
    },
  );
  test('member count can be unknown while actual hours are available', () {
    final impact = CommunityImpact.fromEvents([], null, now);
    expect(impact.accounts, isNull);
    expect(impact.hours, 0);
  });
  testWidgets('profile edit offers the Supabase photo picker', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EditInfoScreen(
          profile: ProfileInfo(name: 'Member', location: 'Gothenburg'),
        ),
      ),
    );
    expect(find.byTooltip('Add profile picture'), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey('profile-photo-circle'))),
        const Size(120, 120));
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.photo), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Name'), findsOneWidget);
  });
}
