import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:good_together/screens/edit_info_screen.dart';
import 'package:good_together/theme/app_theme.dart';
import 'package:good_together/widgets/category_chips.dart';
import 'package:good_together/main.dart';
import 'package:good_together/data/sample_opportunities.dart';
import 'package:good_together/models/opportunity.dart';
import 'package:good_together/screens/map_screen.dart';
import 'package:good_together/screens/pick_location_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('edit info saves the visible profile details', (tester) async {
    ProfileInfo? saved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  saved = await Navigator.push<ProfileInfo>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditInfoScreen(
                        profile: ProfileInfo(
                          name: 'Linnea Mårtensson',
                          location: 'Gothenburg, Sweden',
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Edit info'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Edit info'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Save changes')).height,
      greaterThanOrEqualTo(44),
    );
    await tester.enterText(find.byType(TextFormField).at(0), 'Alex Andersson');
    await tester.enterText(find.byType(TextFormField).at(1), 'Majorna, Sweden');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(saved?.name, 'Alex Andersson');
    expect(saved?.location, 'Majorna, Sweden');
  });

  testWidgets('failed profile save retains input and allows retry', (
    tester,
  ) async {
    int attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: EditInfoScreen(
          profile: const ProfileInfo(name: 'Member', location: 'Sweden'),
          onSave: (info) async {
            attempts++;
            if (attempts == 1) throw StateError('Offline');
          },
        ),
      ),
    );
    await tester.enterText(find.byType(TextFormField).first, 'Alex');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not save profile:'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).first)
          .controller!
          .text,
      'Alex',
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Save changes'),
          )
          .onPressed,
      isNotNull,
    );
    expect(attempts, 1);
  });

  testWidgets('category chips have readable labels and 44-pixel targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CategoryChips(selected: {'All'}, onSelected: (_) {}),
        ),
      ),
    );
    for (final chip in tester.widgetList<FilterChip>(find.byType(FilterChip))) {
      final finder = find.byWidget(chip);
      expect(tester.getSize(finder).width, greaterThanOrEqualTo(44));
      expect(tester.getSize(finder).height, greaterThanOrEqualTo(44));
      final label = chip.label as Text;
      expect(chip.labelStyle!.color, AppColors.navy);
      expect(label.data, isNotEmpty);
    }
  });

  testWidgets(
      'main screens fit a narrow phone and guest My Page offers sign in', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GoodTogetherApp());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.widgetWithText(TextButton, 'See your impact')).height,
      greaterThanOrEqualTo(44),
    );
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sign in to view My Page.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Serve warm lunch').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Serve warm lunch').first);
    await tester.pumpAndSettle();
    expect(find.text('3 spots left'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('map markers open their matching opportunity', (tester) async {
    Opportunity? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
              child: MapScreen(
            area: 'Majorna',
            opportunities: sampleOpportunities,
            onOpen: (item) => opened = item,
          )),
        ),
      ),
    );
    await tester.pump();
    final marker = find.byTooltip('Serve warm lunch');
    expect(tester.getSize(marker).width, greaterThanOrEqualTo(44));
    expect(tester.getSize(marker).height, greaterThanOrEqualTo(44));
    await tester.tap(marker);
    expect(opened?.title, 'Serve warm lunch');
  });

  testWidgets('a new opportunity can select a map pin', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const PickLocationScreen()),
    );
    await tester.pump();
    final save = find.widgetWithText(FilledButton, 'Use this location');
    expect(tester.widget<FilledButton>(save).onPressed, isNull);
    await tester.tapAt(tester.getCenter(find.byType(FlutterMap)));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(save).onPressed, isNotNull);
    expect(tester.getSize(save).height, greaterThanOrEqualTo(44));
  });
}
