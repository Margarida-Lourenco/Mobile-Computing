import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/theme/app_theme.dart';
import 'package:good_together/widgets/icon_box.dart';
import 'package:good_together/widgets/opportunity_card.dart';
import 'package:good_together/widgets/sheets/opportunity_details_sheet.dart';
import 'package:good_together/widgets/sheets/post_opportunity_sheet.dart';

Opportunity event(String title) => Opportunity(
      id: 'layout',
      organization: 'Neighbourhood volunteers',
      title: title,
      date: '25 December',
      time: '10:00 – 12:00',
      place: 'A longer meeting point in Gamlestaden, Gothenburg',
      distance: '',
      category: 'Outdoors',
      description: 'Help plant trees.',
      spots: 4,
      icon: Icons.park,
      latitude: 57.729,
      longitude: 12.005,
      startsAt: DateTime(2027, 12, 25, 10),
      endsAt: DateTime(2027, 12, 25, 12),
    );

void main() {
  test('title validation uses human-visible characters and a 60-character cap',
      () {
    expect(Opportunity.isValidTitle(' '), isFalse);
    expect(Opportunity.isValidTitle('a' * 60), isTrue);
    expect(Opportunity.isValidTitle('a' * 61), isFalse);
    expect(Opportunity.isValidTitle('🌳' * 60), isTrue);
    expect(Opportunity.isValidTitle('🌳' * 61), isFalse);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets(
        'large photo, wrapped title and independent favorite at text scale $scale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var opens = 0, favorites = 0;
      const title = 'Carry storm-fallen branches to my garden collection pile';
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
                body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: OpportunityCard(
                  item: event(title),
                  favorite: false,
                  onOpen: () => opens++,
                  onFavorite: () => favorites++),
            )),
          )));
      final photo = tester.getRect(find.byKey(const ValueKey('listing-photo')));
      expect(photo.width, 278); // The card has a one-pixel border on each side.
      expect(photo.height, closeTo(photo.width * 9 / 16, 0.1));
      final heart = tester.getRect(find.byTooltip('Add to favorites'));
      expect(heart.center.dy, lessThan(photo.top + photo.height / 3));
      expect(heart.center.dx, greaterThan(photo.right - photo.width / 4));
      expect(photo.contains(heart.center), isTrue);
      final rich = find.descendant(
          of: find.text(title), matching: find.byType(RichText));
      expect(tester.renderObject<RenderParagraph>(rich).didExceedMaxLines,
          isFalse);
      expect(tester.widget<Text>(find.text(title)).maxLines, isNull);
      await tester.tap(find.byTooltip('Add to favorites'));
      expect(favorites, 1);
      expect(opens, 0);
      await tester.tapAt(photo.center);
      expect(opens, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'posting caps input at 60 characters and rejects oversized existing titles',
      (tester) async {
    var saves = 0;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: PostOpportunitySheet(
          existing: event('a' * 61),
          onPublished: (_) {},
          onSave: (event, photo) async {
            saves++;
          },
        )));
    await tester.ensureVisible(find.text('Publish opportunity'));
    await tester.tap(find.text('Publish opportunity'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.textContaining('Keep the title within 60 characters'),
        findsOneWidget);
    final field = find.widgetWithText(TextField, 'Opportunity title');
    await tester.ensureVisible(field);
    await tester.enterText(field, 'b' * 70);
    expect(tester.widget<TextField>(field).controller!.text.length, 60);
    expect(tester.widget<TextField>(field).maxLength, 60);
    expect(tester.takeException(), isNull);
  });

  testWidgets('details omit the decorative green icon', (tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: OpportunityDetailsSheet(
      item: event('Plant neighbourhood trees'),
      isFavorite: false,
      isJoined: false,
      onFavorite: () {},
      onJoin: () {},
      onInvite: () {},
    ))));
    expect(find.byType(IconBox), findsNothing);
    expect(find.text('Plant neighbourhood trees'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
