import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/main.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/screens/auth_screen.dart';
import 'package:good_together/theme/app_theme.dart';
import 'package:good_together/widgets/app_sheet.dart';
import 'package:good_together/widgets/bottom_nav.dart';
import 'package:good_together/widgets/opportunity_card.dart';
import 'package:good_together/widgets/sheets/opportunity_details_sheet.dart';

void setViewport(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(390, 640),
    const Size(1366, 768)
  ]) {
    testWidgets(
        'footer remains visible and last card clears navigation at $size',
        (tester) async {
      setViewport(tester, size);
      await tester.pumpWidget(const GoodTogetherApp());
      await tester.pumpAndSettle();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.bottomNavigationBar, isA<AppBottomNav>());
      final nav = find.byType(AppBottomNav);
      final before = tester.getRect(nav);
      expect(before.bottom, closeTo(size.height, 1));
      final scroll = tester.state<ScrollableState>(find
          .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable))
          .first);
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pumpAndSettle();
      final lastCard = tester.getRect(find.byType(OpportunityCard).last);
      expect(
          lastCard.bottom, lessThanOrEqualTo(tester.getTopLeft(nav).dy - 16));
      expect(tester.getRect(nav), before);
      for (final label in [
        'Discover',
        'Map',
        'Post',
        'Notifications',
        'My Page'
      ]) {
        final rect = tester.getRect(find.text(label));
        expect(rect.top, greaterThanOrEqualTo(before.top));
        expect(rect.bottom, lessThanOrEqualTo(size.height));
      }
      await tester.tap(find.text('My Page'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in to view My Page.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
      'details wrap a long address and reveal final action on a short viewport',
      (tester) async {
    setViewport(tester, const Size(320, 480));
    final event = Opportunity(
        id: 'test',
        title: 'Help neighbors with a community event',
        organization: 'Community group',
        date: '19 October 2027',
        time: '10:00 – 12:00',
        place:
            'A very long meeting place and street address in Gothenburg, Sweden',
        distance: '',
        category: 'Social',
        description: List.filled(40,
                'A longer description with all the instructions volunteers need.')
            .join(' '),
        spots: 10,
        icon: Icons.people,
        startsAt: DateTime(2027, 10, 19, 10),
        endsAt: DateTime(2027, 10, 19, 12));
    var joined = false;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: Builder(
                builder: (context) => TextButton(
                    onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (_) => OpportunityDetailsSheet(
                            item: event,
                            isFavorite: false,
                            isJoined: false,
                            onFavorite: () {},
                            onJoin: () {
                              joined = true;
                            },
                            onInvite: () {})),
                    child: const Text('Open details'))))));
    await tester.tap(find.text('Open details'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final sheet = tester.getRect(find.byType(AppSheet));
    expect(sheet.top, greaterThanOrEqualTo(0));
    expect(sheet.bottom, lessThanOrEqualTo(480));
    await tester.ensureVisible(find.text('I want to help'));
    await tester.pumpAndSettle();
    expect(
        tester.getBottomRight(find.text('I want to help')).dy, lessThan(480));
    await tester.tap(find.text('I want to help'));
    expect(joined, isTrue);
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(390, 740), const Size(1366, 768)]) {
    testWidgets(
        'sign in has matching top color and centered bounded form at $size',
        (tester) async {
      setViewport(tester, size);
      await tester.pumpWidget(
          MaterialApp(theme: AppTheme.light, home: const AuthScreen()));
      await tester.pumpAndSettle();
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, AppColors.background);
      expect(appBar.surfaceTintColor, Colors.transparent);
      final form = tester.getRect(find.byKey(const ValueKey('auth-form')));
      final body = tester.getRect(find.byType(LayoutBuilder));
      expect(form.center.dx, closeTo(body.center.dx, 1));
      expect(form.center.dy, closeTo(body.center.dy, 1));
      expect(form.width, lessThanOrEqualTo(420));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('registration remains scrollable above a keyboard',
      (tester) async {
    setViewport(tester, const Size(320, 480));
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AuthScreen()));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Create an account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester
        .ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(
        tester
            .getBottomRight(find.widgetWithText(FilledButton, 'Create account'))
            .dy,
        lessThanOrEqualTo(260));
    expect(tester.takeException(), isNull);
  });
}
