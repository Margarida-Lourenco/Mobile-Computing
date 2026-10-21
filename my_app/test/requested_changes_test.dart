import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:good_together/main.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/models/opportunity_filters.dart';
import 'package:good_together/screens/map_screen.dart';
import 'package:good_together/theme/category_style.dart';
import 'package:good_together/widgets/category_chips.dart';

Opportunity event(String id, String category, DateTime start) => Opportunity(
  id: id,
  title: id,
  category: category,
  organization: 'Host',
  date: '',
  time: '2:00 PM – 4:00 PM',
  place: 'Gothenburg',
  distance: '',
  description: '',
  spots: 10,
  icon: Icons.people,
  startsAt: start,
  endsAt: start.add(const Duration(hours: 2)),
  latitude: 57.71,
  longitude: 11.94,
);
void main() {
  testWidgets('notifications omit the shared greeting', (tester) async {
    await tester.pumpWidget(const GoodTogetherApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hej,'), findsNothing);
    expect(find.text('Sign in to see your notifications.'), findsOneWidget);
  });
  test('each category has a distinct marker colour and symbol', () {
    final styles = OpportunityFilters.categories
        .map(CategoryStyle.forCategory)
        .toList();
    expect(OpportunityFilters.categories, contains('Other'));
    expect(styles.map((s) => s.color).toSet().length, styles.length);
    expect(styles.map((s) => s.icon).toSet().length, styles.length);
    expect(
      CategoryStyle.forCategory('Community').color,
      CategoryStyle.forCategory('Social').color,
    );
    expect(
      CategoryStyle.forCategory('Unknown').icon,
      CategoryStyle.forCategory('Other').icon,
    );
  });
  test(
    'All is exclusive and removing the last specific filter restores All',
    () {
      var selected = OpportunityFilters.toggle({'All'}, 'Social');
      expect(selected, {'Social'});
      selected = OpportunityFilters.toggle(selected, 'Animals');
      expect(selected, {'Social', 'Animals'});
      expect(OpportunityFilters.toggle(selected, 'All'), {'All'});
      expect(OpportunityFilters.toggle({'Social'}, 'Social'), {'All'});
    },
  );
  test(
    'Today and categories use OR across the full requested category set',
    () {
      final today = DateTime(2026, 10, 19, 14);
      final tomorrow = today.add(const Duration(days: 1));
      expect(
        OpportunityFilters.matches(event('today', 'Culture', today), {
          'Today',
          'Animals',
        }, today),
        isTrue,
      );
      expect(
        OpportunityFilters.matches(event('animals', 'Animals', tomorrow), {
          'Today',
          'Animals',
        }, today),
        isTrue,
      );
      expect(
        OpportunityFilters.matches(event('other', 'Sports', tomorrow), {
          'Today',
          'Animals',
        }, today),
        isFalse,
      );
      for (final category in OpportunityFilters.categories) {
        expect(
          OpportunityFilters.matches(event(category, category, tomorrow), {
            category,
          }, today),
          isTrue,
        );
      }
      expect(
        OpportunityFilters.matches(event('legacy', 'Food', tomorrow), {
          'Social',
        }, today),
        isTrue,
      );
    },
  );
  test('timestamp and legacy time strings display in 24-hour format', () {
    expect(
      event('clock', 'Social', DateTime(2026, 10, 19, 14, 5)).time,
      '14:05 – 16:05',
    );
    const legacy = Opportunity(
      id: 'legacy',
      title: '',
      category: 'Social',
      organization: '',
      date: '',
      time: '12:00 AM – 2:30 PM',
      place: '',
      distance: '',
      description: '',
      spots: 1,
      icon: Icons.people,
    );
    expect(legacy.time, '00:00 – 14:30');
  });
  testWidgets(
    'chips follow requested order and show multiple selected states',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryChips(
              selected: const {'Social', 'Animals'},
              onSelected: (_) {},
            ),
          ),
        ),
      );
      final chips = tester
          .widgetList<FilterChip>(find.byType(FilterChip))
          .toList();
      expect(
        chips.map((c) => (c.label as Text).data),
        OpportunityFilters.labels,
      );
      expect(
        chips.where((c) => c.selected).map((c) => (c.label as Text).data),
        ['Social', 'Animals'],
      );
    },
  );
  testWidgets(
    'guests land on Discover and get login prompt for post and favorites',
    (tester) async {
      await tester.pumpWidget(const GoodTogetherApp());
      await tester.pumpAndSettle();
      expect(find.text('Gothenburg is showing up.'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
      expect(
        MediaQuery.of(tester.element(find.byType(CategoryChips)))
            .alwaysUse24HourFormat,
        isTrue,
      );
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to take part'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
      await tester.tap(find.text('Keep browsing'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.favorite_border).first);
      await tester.pumpAndSettle();
      expect(find.text('Sign in to take part'), findsOneWidget);
      await tester.tap(find.text('Keep browsing'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Serve warm lunch').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Serve warm lunch').first);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('I want to help'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('I want to help'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to take part'), findsOneWidget);
    },
  );
  testWidgets('map list selects, enlarges and centers the matching marker', (
    tester,
  ) async {
    final item = event(
      'Select this event',
      'Animals',
      DateTime.now().add(const Duration(days: 1)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MapScreen(
              opportunities: [item],
              area: 'Majorna',
              onOpen: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(ListTile, item.title));
    await tester.tap(find.widgetWithText(ListTile, item.title));
    await tester.pumpAndSettle();
    final map = tester.widget<FlutterMap>(find.byType(FlutterMap));
    expect(
      map.mapController!.camera.center.latitude,
      closeTo(item.latitude!, 0.0001),
    );
    expect(
      map.mapController!.camera.center.longitude,
      closeTo(item.longitude!, 0.0001),
    );
    final marker = tester
        .widget<MarkerLayer>(find.byType(MarkerLayer))
        .markers
        .single;
    expect(marker.width, 64);
    final button = marker.child as IconButton;
    expect((button.icon as Icon).icon, Icons.pets_rounded);
    expect(
      button.style!.backgroundColor!.resolve({}),
      CategoryStyle.forCategory('Animals').color,
    );
    expect(
      tester
          .widget<ListTile>(find.widgetWithText(ListTile, item.title))
          .selected,
      isTrue,
    );
  });
}
