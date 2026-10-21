import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/data/city_areas.dart';
import 'package:good_together/theme/app_theme.dart';
import 'package:good_together/widgets/sheets/area_picker_sheet.dart';
import 'package:good_together/widgets/sheets/post_opportunity_sheet.dart';

void main() {
  testWidgets('posting is a full page with full-width date and a time range',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var saves = 0;
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: Builder(
              builder: (context) => TextButton(
                    onPressed: () =>
                        Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PostOpportunitySheet(
                        onPublished: (_) {},
                        onSave: (event, photo) async {
                          saves++;
                        },
                      ),
                    )),
                    child: const Text('Open'),
                  ))),
    ));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
    expect(tester.getSize(find.byType(Scaffold).last), const Size(320, 568));
    final date = find.byKey(const ValueKey('post-date'));
    final start = find.byKey(const ValueKey('post-start'));
    final end = find.byKey(const ValueKey('post-end'));
    await tester.ensureVisible(end);
    await tester.pumpAndSettle();
    expect(tester.getSize(date).width, 280);
    expect(tester.getCenter(start).dy, tester.getCenter(end).dy);
    expect(tester.getTopLeft(start).dx, tester.getTopLeft(date).dx);
    expect(tester.getBottomRight(end).dx, tester.getBottomRight(date).dx);
    expect(tester.getCenter(date).dy, lessThan(tester.getCenter(start).dy));
    tester.view.viewInsets = const FakeViewPadding(bottom: 240);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Publish opportunity'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publish opportunity'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Please add:'), findsOneWidget);
    expect(saves, 0);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(PostOpportunitySheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'area picker offers city-wide choices without descriptions and supports accented search',
      (tester) async {
    String? selected;
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => AreaPickerSheet(
              currentArea: 'Majorna', onSelected: (area) => selected = area),
        ),
        child: const Text('Choose'),
      ),
    ))));
    await tester.tap(find.text('Choose'));
    await tester.pumpAndSettle();
    for (final area in [
      'All Gothenburg',
      'Centrum',
      'Hisingen',
      'Nordost',
      'Sydväst',
      'Gamlestaden',
      'Frölunda',
      'Södra skärgården'
    ]) {
      expect(areaCenters.containsKey(area), isTrue);
      expect(find.text(area), findsOneWidget);
    }
    expect(
        tester
            .widgetList<ListTile>(find.byType(ListTile))
            .every((tile) => tile.subtitle == null),
        isTrue);
    await tester.enterText(find.byType(TextField), 'frolunda');
    await tester.pump();
    expect(find.byType(ListTile), findsOneWidget);
    await tester.ensureVisible(find.text('Frölunda'));
    await tester.tap(find.text('Frölunda'));
    await tester.pumpAndSettle();
    expect(selected, 'Frölunda');
    expect(find.byType(AreaPickerSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
