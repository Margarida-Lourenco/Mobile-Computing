import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/theme/app_theme.dart';
import 'package:good_together/widgets/sheets/post_opportunity_sheet.dart';

Opportunity validEvent({bool withEnd = true}) => Opportunity(
      id: 'test',
      title: 'Help neighbors',
      organization: 'Host',
      place: 'Park',
      description: 'Clean the park',
      category: 'Community',
      date: '7 Oct',
      time: '10:00',
      distance: '',
      spots: 4,
      icon: Icons.people,
      latitude: 57.7,
      longitude: 11.9,
      startsAt: DateTime(2027, 10, 7, 10),
      endsAt: withEnd ? DateTime(2027, 10, 7, 12) : null,
    );
Future<void> openForm(
  WidgetTester tester, {
  Opportunity? existing,
  required Future<void> Function() save,
  required VoidCallback published,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => PostOpportunitySheet(
                existing: existing,
                onSave: (_, photo) => save(),
                onPublished: (_) => published(),
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
  await tester.ensureVisible(find.text('Publish opportunity'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('end time is mandatory even when all other details are filled', (
    tester,
  ) async {
    var saves = 0;
    await openForm(
      tester,
      existing: validEvent(withEnd: false),
      save: () async {
        saves++;
      },
      published: () {},
    );
    await tester.tap(find.text('Publish opportunity'));
    await tester.pumpAndSettle();
    expect(saves, 0);
    expect(find.text('Please add: end time.'), findsOneWidget);
  });

  testWidgets(
    'missing details are visible beside Publish and no save is attempted',
    (tester) async {
      int saves = 0;
      await openForm(
        tester,
        save: () async {
          saves++;
        },
        published: () {},
      );
      await tester.tap(find.text('Publish opportunity'));
      await tester.pumpAndSettle();
      expect(saves, 0);
      expect(find.textContaining('Please add:'), findsOneWidget);
      expect(
        find.textContaining('map pin (choose Use this location)'),
        findsOneWidget,
      );
      final errorPosition = tester.getCenter(
        find.byKey(const ValueKey('publishError')),
      );
      expect(errorPosition.dy, greaterThan(0));
      expect(
        errorPosition.dy,
        lessThan(
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        ),
      );
    },
  );
  testWidgets(
    'pending save shows progress, prevents duplicate writes and successful save closes form',
    (tester) async {
      final save = Completer<void>();
      int saves = 0;
      bool published = false;
      await openForm(
        tester,
        existing: validEvent(),
        save: () {
          saves++;
          return save.future;
        },
        published: () => published = true,
      );
      await tester.tap(find.text('Publish opportunity'));
      await tester.pump();
      expect(find.text('Saving…'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Saving…'))
            .onPressed,
        isNull,
      );
      expect(saves, 1);
      expect(published, isFalse);
      save.complete();
      await tester.pumpAndSettle();
      expect(published, isTrue);
      expect(find.byType(PostOpportunitySheet), findsNothing);
    },
  );
  testWidgets(
    'failed save displays error near Publish and retains details for retry',
    (tester) async {
      int saves = 0;
      await openForm(
        tester,
        existing: validEvent(),
        save: () async {
          saves++;
          throw StateError('Connection failed');
        },
        published: () {},
      );
      await tester.tap(find.text('Publish opportunity'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not publish:'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Help neighbors'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Publish opportunity'),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.text('Publish opportunity'));
      await tester.pumpAndSettle();
      expect(saves, 2);
    },
  );
}
