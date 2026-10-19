import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_together/services/account_registration.dart';
import 'package:good_together/screens/auth_screen.dart';
import 'package:good_together/screens/edit_info_screen.dart';
import 'package:good_together/theme/app_theme.dart';
import 'package:good_together/widgets/join_confirmation.dart';

void main() {
  test('username validation accepts valid names and rejects invalid names', () {
    expect(AccountRegistration.validateUsername('wilma_123'), isNull);
    expect(AccountRegistration.validateUsername('ab'), isNotNull);
    expect(AccountRegistration.validateUsername('a' * 25), isNotNull);
    expect(AccountRegistration.validateUsername('has spaces'), isNotNull);
  });
  test('username is used in greeting with legacy name fallback', () {
    const profile = ProfileInfo(
      name: 'Wilma Andersson',
      username: 'wilma_123',
      location: 'Sweden',
    );
    expect(profile.firstName, 'wilma_123');
    expect(profile.displayUsername, 'wilma_123');
    const legacy = ProfileInfo(name: 'Wilma Andersson', location: 'Sweden');
    expect(legacy.firstName, 'Wilma');
    expect(legacy.displayUsername, 'Wilma Andersson');
  });
  testWidgets(
    'registration asks for username and blocks invalid account data',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AuthScreen()),
      );
      expect(find.widgetWithText(TextFormField, 'Username'), findsNothing);
      await tester.tap(find.text('Create an account'));
      await tester.pump();
      expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pump();
      expect(
        find.text('Use 3–24 letters, numbers or underscores.'),
        findsOneWidget,
      );
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(
        find.text('Use a password with at least 6 characters.'),
        findsOneWidget,
      );
    },
  );
  testWidgets('join confirmation uses one-second duration and disappears', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showJoinConfirmation(context),
              child: const Text('Show'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Show'));
    await tester.pump();
    expect(
      tester.widget<SnackBar>(find.byType(SnackBar)).duration,
      const Duration(seconds: 1),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(
      find.text('You’re signed up! Thank you for helping.'),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });
}
