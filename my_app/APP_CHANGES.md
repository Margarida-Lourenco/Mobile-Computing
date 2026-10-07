# Latest app changes

1. Appearance is centralized in `lib/theme/app_theme.dart`: AppColors, AppFonts, AppTextStyles, AppRadii, AppSpacing, AppIconSizes and widget theme defaults. Change the constants, then hot reload; if a font-family change does not refresh, hot restart. Existing appearance and map behavior are preserved.
2. Badge symbols use the Material ribbon/medal icon `workspace_premium_outlined`.
3. After a join write succeeds, a floating confirmation banner displays for one second. Leaving an event or a failed write does not display success. This requires a connected account; preview mode does not claim to save joins.
4. Event creation says Host. The existing Firestore `organization` field is retained for compatibility with events already saved.
5. Registration includes a required username (3–24 letters, digits or underscores). It is saved to Auth displayName and Firestore users/{uid}.username; the app uses it in the greeting and My Page. Usernames are display names and do not need to be globally unique. Email remains the sign-in credential. Existing profiles continue to use their saved name when no username is present.

## Apply this update to your configured project

Your Firebase configuration and Android Firebase build settings from Mobile-Computing-main (2).zip have been preserved. You do not need to copy configuration files from the older download or rerun flutterfire configure for the already configured platforms.

Publish the updated firestore.rules in Firebase Console > Firestore Database > Rules, replacing the old rules, then click Publish. The new rules allow the username field. Do this before trying new registrations. Storage rules are unchanged.

Run flutter pub get, then flutter run. There is no new paid service in this update. Continue using Spark for accounts/events without photo uploads; Firebase photo uploads still require Blaze.
