import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/models/reward_progress.dart';
import 'package:good_together/screens/my_page_screen.dart';
import 'package:good_together/screens/edit_info_screen.dart';
import 'package:good_together/widgets/bottom_nav.dart';
import 'package:good_together/widgets/opportunity_card.dart';
import 'package:good_together/widgets/event_calendar.dart';

Opportunity shift(
  String id, {
  DateTime? start,
  DateTime? end,
  bool cancelled = false,
}) =>
    Opportunity(
      id: id,
      title: id,
      organization: 'Helpers',
      date: '',
      time: '',
      place: '',
      distance: '',
      category: 'Community',
      description: '',
      spots: 4,
      icon: Icons.people,
      startsAt: start,
      endsAt: end,
      cancelled: cancelled,
    );

void main() {
  final now = DateTime(2026, 10, 14, 12);
  test(
      'feed/map availability respects end boundary, cancellation and missing dates',
      () {
    final ongoing = shift(
      'ongoing',
      start: now.subtract(const Duration(hours: 1)),
      end: now.add(const Duration(hours: 1)),
    );
    expect(ongoing.isAvailable(now), isTrue);
    expect(ongoing.isAvailable(now.add(const Duration(hours: 1))), isFalse);
    expect(
      shift(
        'past',
        end: now.subtract(const Duration(seconds: 1)),
      ).isAvailable(now),
      isFalse,
    );
    expect(shift('start-only', start: now).hasEnded(now), isTrue);
    expect(shift('unknown').isAvailable(now), isFalse);
    expect(
      shift(
        'cancelled',
        end: now.add(const Duration(days: 1)),
        cancelled: true,
      ).isAvailable(now),
      isFalse,
    );
  });
  test('only joined, ended, non-cancelled shifts earn levels and hours', () {
    final events = [
      shift(
        'completed',
        start: now.subtract(const Duration(hours: 3)),
        end: now,
      ),
      shift('future', start: now.add(const Duration(days: 1))),
      shift('cancelled', end: now, cancelled: true),
      shift('unjoined', end: now),
    ];
    final fresh = RewardProgress.fromShifts(events, {}, now);
    expect(fresh.level, 1);
    expect(fresh.badgesEarned, 0);
    expect(fresh.progress, 0);
    expect(
      RewardProgress.fromShifts(
        [shift('legacy', start: now.subtract(const Duration(days: 1)))],
        {'legacy'},
        now,
      ).level,
      1,
    );
    expect(
      RewardProgress.fromShifts(
        [shift('invalid', start: now, end: now)],
        {'invalid'},
        now,
      ).level,
      1,
    );
    final earned = RewardProgress.fromShifts(
        events,
        {
          'completed',
          'future',
          'cancelled',
        },
        now);
    expect(earned.completed, 1);
    expect(earned.hours, 3);
    expect(earned.level, 2);
    expect(earned.badgesEarned, 2);
    expect(const RewardProgress(completed: 3).level, 3);
    expect(const RewardProgress(completed: 5).level, 4);
    expect(const RewardProgress(completed: 10).level, 5);
  });
  testWidgets(
    'past shifts stay separate from agenda and calendar; sign out is at bottom',
    (tester) async {
      final today = DateTime.now();
      final events = [
        shift('Past shift', end: today.subtract(const Duration(days: 1))),
        shift('Upcoming shift', start: today.add(const Duration(days: 1))),
        shift('Other past shift', end: today.subtract(const Duration(days: 1))),
      ];
      var signedOut = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MyPageScreen(
                opportunities: events,
                joined: {'Past shift', 'Upcoming shift'},
                favorites: {},
                posted: {},
                profile: const ProfileInfo(
                  name: 'Member',
                  location: 'Gothenburg',
                ),
                onEditInfo: () {},
                onOpen: (_) {},
                onFavorite: (_) {},
                onRewards: () {},
                onPost: () {},
                onSignOut: () {
                  signedOut = true;
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('My shifts'), findsOneWidget);
      expect(find.text('LEVEL 1 · NEW NEIGHBOR'), findsOneWidget);
      await tester.ensureVisible(find.text('Past'));
      await tester.tap(find.text('Past'));
      await tester.pump();
      expect(
        tester
            .widgetList<OpportunityCard>(find.byType(OpportunityCard))
            .map((c) => c.item.id),
        ['Past shift'],
      );
      await tester.tap(find.byTooltip('Calendar'));
      await tester.pump();
      expect(
          tester
              .widget<EventCalendar>(find.byType(EventCalendar))
              .events
              .map((event) => event.id),
          ['Past shift']);
      await tester.tap(find.byTooltip('Agenda'));
      await tester.pump();
      expect(
          tester
              .widgetList<OpportunityCard>(find.byType(OpportunityCard))
              .map((card) => card.item.id),
          ['Past shift']);
      await tester.tap(find.text('Upcoming'));
      await tester.pump();
      await tester.ensureVisible(find.byTooltip('Agenda'));
      await tester.tap(find.byTooltip('Agenda'));
      await tester.pump();
      expect(
        tester
            .widgetList<OpportunityCard>(find.byType(OpportunityCard))
            .map((c) => c.item.id),
        ['Upcoming shift'],
      );
      await tester.ensureVisible(find.text('Sign out'));
      await tester.tap(find.text('Sign out'));
      expect(signedOut, isTrue);
    },
  );
  testWidgets('bottom navigation keeps every label visible', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(index: 0, onTap: (_) {}),
        ),
      ),
    );
    for (final label in [
      'Discover',
      'Map',
      'Post',
      'Notifications',
      'My Page',
    ]) {
      expect(find.text(label), findsOneWidget);
      expect(
        tester.getBottomRight(find.text(label)).dy,
        lessThanOrEqualTo(
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        ),
      );
    }
  });
}
