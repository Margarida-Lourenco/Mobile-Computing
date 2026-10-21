import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/models/app_notification.dart';
import 'package:good_together/services/attendance_change.dart';
import 'package:good_together/widgets/event_calendar.dart';
import 'package:good_together/widgets/bottom_nav.dart';
import 'package:good_together/widgets/sheets/post_opportunity_sheet.dart';
import 'package:good_together/screens/my_page_screen.dart';
import 'package:good_together/screens/edit_info_screen.dart';
import 'package:good_together/theme/app_theme.dart';

Opportunity fixture({
  int count = 0,
  int day = 7,
  int endHour = 12,
  String? cover,
}) =>
    Opportunity(
      id: 'event-$day',
      organization: 'Host',
      title: 'Event $day',
      date: '$day Oct',
      time: '10:00 – 12:00',
      place: 'Street',
      distance: '',
      category: 'Community',
      description: 'Help',
      spots: 4,
      attendeeCount: count,
      icon: Icons.people,
      latitude: 57.7,
      longitude: 11.9,
      startsAt: DateTime(2027, 10, day, 10),
      endsAt: DateTime(2027, 10, day, endHour),
      coverImageUrl: cover,
    );
Future<void> editor(
  WidgetTester tester,
  Opportunity item,
  ValueChanged<Opportunity> saved,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PostOpportunitySheet(
                existing: item,
                onSave: (e, photo) async {
                  saved(e);
                },
                onPublished: (_) {},
              ),
            )),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'remaining places reflect attendance and end time survives Firestore',
    () {
      final item = fixture(count: 3);
      expect(item.spotsLeft, 1);
      final restored = Opportunity.fromFirestore(item.id, {
        ...item.toFirestore(),
        'attendeeCount': 3,
      });
      expect(restored.endsAt, item.endsAt);
      expect(restored.spotsLeft, 1);
    },
  );
  test(
    'duplicate joins do not change attendance and full events reject entry',
    () {
      final duplicate = AttendanceChange.calculate(
        capacity: 4,
        count: 2,
        revision: 8,
        alreadyJoined: true,
        joining: true,
        cancelled: false,
      );
      expect(duplicate.changed, isFalse);
      expect(duplicate.count, 2);
      expect(duplicate.revision, 8);
      expect(
        () => AttendanceChange.calculate(
          capacity: 2,
          count: 2,
          revision: 8,
          alreadyJoined: false,
          joining: true,
          cancelled: false,
        ),
        throwsStateError,
      );
    },
  );
  test(
    'withdrawal restores one place and advances the transaction revision',
    () {
      final result = AttendanceChange.calculate(
        capacity: 4,
        count: 4,
        revision: 8,
        alreadyJoined: true,
        joining: false,
        cancelled: false,
      );
      expect(result.count, 3);
      expect(result.revision, 9);
      expect(result.changed, isTrue);
    },
  );
  test(
    'cancelled events reject membership changes',
    () => expect(
      () => AttendanceChange.calculate(
        capacity: 4,
        count: 0,
        revision: 0,
        alreadyJoined: false,
        joining: true,
        cancelled: true,
      ),
      throwsStateError,
    ),
  );
  test('notifications explain joins, signups and withdrawals', () {
    AppNotification n(String kind) => AppNotification(
          id: 'n',
          eventId: 'event',
          title: 'Cleanup',
          actorName: 'Wilma',
          kind: kind,
        );
    expect(n('joined').message, 'You joined Cleanup.');
    expect(n('signup').message, 'Wilma signed up for Cleanup.');
    expect(n('withdrawal').message, 'Wilma left Cleanup.');
    expect(n('cancelled').message, contains('cancelled'));
  });
  testWidgets('calendar marks joined dates and selects a marked date', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EventCalendar(
            selectedDate: DateTime(2027, 10, 1),
            events: [fixture(day: 7), fixture(day: 8)],
            onSelected: (d) => selected = d,
          ),
        ),
      ),
    );
    expect(find.byKey(const ValueKey('event-dot-2027-10-7')), findsOneWidget);
    expect(find.byKey(const ValueKey('event-dot-2027-10-8')), findsOneWidget);
    expect(find.byKey(const ValueKey('event-dot-2027-10-9')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('calendar-2027-10-7')));
    expect(selected, DateTime(2027, 10, 7));
  });
  testWidgets(
    'activity categories and secondary view controls fit a narrow phone',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: MyPageScreen(
                opportunities: [fixture()],
                joined: const {'event-7'},
                favorites: const {},
                posted: const {},
                profile: const ProfileInfo(name: 'Wilma', location: 'Sweden'),
                onOpen: (_) {},
                onFavorite: (_) {},
                onRewards: () {},
                onPost: () {},
                onEditInfo: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SegmentedButton<String>), findsNothing);
      await tester.ensureVisible(find.byTooltip('Agenda'));
      await tester.tap(find.byTooltip('Agenda'));
      await tester.pumpAndSettle();
      expect(find.text('Event 7'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('notifications destination is between Post and My Page', (
    tester,
  ) async {
    int? destination;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(
            index: 0,
            unreadCount: 2,
            onTap: (i) => destination = i,
          ),
        ),
      ),
    );
    final labels = ['Discover', 'Map', 'Post', 'Notifications', 'My Page'];
    for (var i = 0; i < labels.length; i++) {
      expect(find.text(labels[i]), findsOneWidget);
      if (i > 0) {
        expect(
          tester.getCenter(find.text(labels[i])).dx,
          greaterThan(tester.getCenter(find.text(labels[i - 1])).dx),
        );
      }
    }
    await tester.tap(find.byIcon(Icons.notifications_outlined));
    expect(destination, 3);
  });
  testWidgets('posting offers a cover photo and retains the address field', (
    tester,
  ) async {
    Opportunity? saved;
    await editor(
      tester,
      fixture(cover: 'https://example.com/cover.jpg'),
      (e) => saved = e,
    );
    expect(find.text('Remove cover photo'), findsNothing);
    expect(find.text('Choose event cover photo'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Address'), findsOneWidget);
    await tester.ensureVisible(find.text('Publish opportunity'));
    await tester.tap(find.text('Publish opportunity'));
    await tester.pumpAndSettle();
    expect(saved!.removeCoverImage, isFalse);
    expect(saved!.endsAt, DateTime(2027, 10, 7, 12));
  });
  testWidgets('end time must be later than start time', (tester) async {
    bool saved = false;
    await editor(tester, fixture(endHour: 9), (_) => saved = true);
    await tester.ensureVisible(find.text('Publish opportunity'));
    await tester.tap(find.text('Publish opportunity'));
    await tester.pumpAndSettle();
    expect(saved, isFalse);
    expect(find.textContaining('Choose an end time later'), findsOneWidget);
  });
}
