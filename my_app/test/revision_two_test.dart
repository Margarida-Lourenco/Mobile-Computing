import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/models/community_impact.dart';
import 'package:good_together/screens/discover_screen.dart';
import 'package:good_together/screens/my_page_screen.dart';
import 'package:good_together/screens/edit_info_screen.dart';
import 'package:good_together/widgets/bottom_nav.dart';

Opportunity event(String id, {DateTime? start, DateTime? end}) => Opportunity(
      id: id,
      title: id,
      organization: 'Host',
      place: '',
      date: '',
      time: '',
      distance: '',
      category: 'Community',
      description: '',
      spots: 1,
      icon: Icons.people,
      startsAt: start,
      endsAt: end,
    );

Widget myPage(List<Opportunity> events, Set<String> joined) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: MyPageScreen(
            opportunities: events,
            joined: joined,
            favorites: {},
            posted: {},
            profile: const ProfileInfo(name: 'Member', location: 'Gothenburg'),
            onEditInfo: () {},
            onOpen: (_) {},
            onFavorite: (_) {},
            onRewards: () {},
            onPost: () {},
          ),
        ),
      ),
    );

void main() {
  testWidgets(
    'My Page starts at level one; a joined future or legacy shift does not advance it',
    (tester) async {
      final now = DateTime.now();
      await tester.pumpWidget(
        myPage(
          [
            event(
              'future',
              start: now.add(const Duration(days: 1)),
              end: now.add(const Duration(days: 1, hours: 2)),
            ),
            event('legacy', start: now.subtract(const Duration(days: 1))),
          ],
          {'future', 'legacy'},
        ),
      );
      expect(find.text('LEVEL 1 · NEW NEIGHBOR'), findsOneWidget);
      await tester.pumpWidget(
        myPage(
          [
            event(
              'completed',
              start: now.subtract(const Duration(hours: 3)),
              end: now.subtract(const Duration(hours: 1)),
            ),
          ],
          {'completed'},
        ),
      );
      expect(find.text('LEVEL 2 · KIND NEIGHBOR'), findsOneWidget);
    },
  );
  testWidgets('Past shifts sits beside Calendar and Agenda at phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(myPage([], {}));
    final agenda = tester.getCenter(find.text('Agenda'));
    final calendar = tester.getCenter(find.text('Calendar'));
    final past = tester.getCenter(find.text('Past shifts'));
    expect(past.dy, closeTo(calendar.dy, 1));
    expect(agenda.dy, closeTo(calendar.dy, 1));
    expect(past.dx, greaterThan(calendar.dx));
    expect(tester.takeException(), isNull);
  });
  testWidgets('Notifications label stays on one line on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNav(index: 0, onTap: (_) {}),
        ),
      ),
    );
    final richFinder = find.descendant(
      of: find.text('Notifications'),
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(richFinder);
    final boxes = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: 13),
    );
    expect(boxes, isNotEmpty);
    expect(boxes.map((box) => box.top).toSet().length, 1);
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(
      tester.getTopLeft(find.text('Notifications')).dx,
      greaterThanOrEqualTo(192),
    );
    expect(
      tester.getBottomRight(find.text('Notifications')).dx,
      lessThanOrEqualTo(256),
    );
    // Increased text scaling must also fit into the same destination width.
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            bottomNavigationBar: AppBottomNav(
              index: 3,
              unreadCount: 2,
              onTap: (_) {},
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.text('Notifications')).dx,
      greaterThanOrEqualTo(192),
    );
    expect(
      tester.getBottomRight(find.text('Notifications')).dx,
      lessThanOrEqualTo(256),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'community card renders real totals instead of the sample counts',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DiscoverScreen(
                opportunities: [],
                favorites: {},
                category: 'All',
                searchController: controller,
                onSearch: (_) {},
                onCategory: (_) {},
                onOpen: (_) {},
                onFavorite: (_) {},
                onImpact: () {},
                onRewards: () {},
                communityImpact: const CommunityImpact(
                  hours: 7.5,
                  accounts: 3,
                  month: '2026-10',
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.text('7.5\nhours shared'), findsOneWidget);
      expect(find.text('3\nmembers'), findsOneWidget);
      expect(find.text('428\nhours shared'), findsNothing);
    },
  );
}
