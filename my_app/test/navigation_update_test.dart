import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/main.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/models/opportunity_order.dart';
import 'package:good_together/widgets/sheets/invite_sheet.dart';
import 'package:good_together/widgets/sheets/opportunity_details_sheet.dart';

Opportunity event(String id, DateTime? start, [DateTime? end]) => Opportunity(
      id: id,
      title: id,
      organization: 'Host',
      date: '',
      time: '',
      place: '',
      distance: '',
      category: 'Social',
      description: '',
      spots: 2,
      icon: Icons.people,
      startsAt: start,
      endsAt: end,
    );

void main() {
  test(
      'ongoing and soonest upcoming first, then recent history and missing dates',
      () {
    final now = DateTime(2026, 10, 21, 12);
    final input = [
      event('Christmas', DateTime(2026, 12, 25)),
      event('last-week', DateTime(2026, 10, 12)),
      event('tomorrow', DateTime(2026, 10, 22)),
      event('ongoing', DateTime(2026, 10, 21, 11), DateTime(2026, 10, 21, 13)),
      event('undated', null),
      event('yesterday', DateTime(2026, 10, 20)),
    ];
    expect(OpportunityOrder.byDate(input, now).map((e) => e.id), [
      'ongoing',
      'tomorrow',
      'Christmas',
      'yesterday',
      'last-week',
      'undated'
    ]);
    expect(input.first.id, 'Christmas');
    expect(
        OpportunityOrder.byDate(input, DateTime(2026, 10, 23)).map((e) => e.id),
        [
          'Christmas',
          'tomorrow',
          'ongoing',
          'yesterday',
          'last-week',
          'undated'
        ]);
  });

  test('equal dates have stable ordering across backend input changes', () {
    final now = DateTime(2026, 10, 21), start = DateTime(2026, 10, 22);
    final a = event('a', start), b = event('b', start);
    expect(OpportunityOrder.byDate([b, a], now).map((e) => e.id), ['a', 'b']);
    expect(OpportunityOrder.byDate([a, b], now).map((e) => e.id), ['a', 'b']);
  });

  testWidgets('floating arrow appears after one viewport and returns to zero',
      (tester) async {
    await tester.pumpWidget(const GoodTogetherApp());
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to top'), findsNothing);
    final scroll = tester.state<ScrollableState>(find
        .descendant(
            of: find.byType(CustomScrollView),
            matching: find.byType(Scrollable))
        .first);
    final screenHeight = scroll.position.viewportDimension;
    scroll.position.jumpTo(screenHeight - 1);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to top'), findsNothing);
    scroll.position.jumpTo(screenHeight);
    await tester.pumpAndSettle();
    expect(find.byTooltip('Back to top'), findsOneWidget);
    expect(tester.getTopLeft(find.byTooltip('Back to top')).dy, lessThan(30));
    expect(tester.getCenter(find.byTooltip('Back to top')).dx,
        tester.view.physicalSize.width / tester.view.devicePixelRatio / 2);
    await tester.tap(find.byTooltip('Back to top'));
    await tester.pumpAndSettle();
    expect(scroll.position.pixels, closeTo(0, 0.1));
    expect(find.byTooltip('Back to top'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'Invite keeps details open and briefly shows Copied Link above the popup',
      (tester) async {
    await tester.pumpWidget(const GoodTogetherApp());
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
        tester.element(find.text('Serve warm lunch')),
        alignment: .3);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serve warm lunch'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Invite'));
    await tester.tap(find.text('Invite'));
    await tester.pumpAndSettle();
    expect(find.byType(InviteSheet), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Copied Link'), findsOneWidget);
    expect(find.byType(OpportunityDetailsSheet), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    expect(
        tester
            .hitTestOnBinding(tester.getCenter(find.text('Copied Link')))
            .path,
        isNotEmpty);
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
    expect(find.text('Copied Link'), findsNothing);
    expect(find.byType(OpportunityDetailsSheet), findsOneWidget);
    await tester.tap(find.text('Invite'));
    await tester.pump();
    expect(find.text('Copied Link'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byType(OpportunityDetailsSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
