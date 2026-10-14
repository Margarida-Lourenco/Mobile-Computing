> Photos have been restored through Supabase. Follow [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for image setup; the original Spark instructions below still apply to Firebase, but statements about uploads being removed are superseded.

# Spark/free-plan setup

This archive works with Firebase Spark. It does not deploy or call Cloud Functions, Cloud Scheduler, or Firebase Storage. Keep the Firebase project on Spark; usage beyond Spark quotas can stop requests rather than enabling pay-as-you-go charges.

## App setup

Use the existing Firebase project configured in lib/firebase_options.dart, enable Email/Password Authentication, and create a Cloud Firestore Standard database if it is not already present. Do not enable phone/SMS sign-in or billing for this version.

From my_app:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
firebase login
firebase deploy --project YOUR_FIREBASE_PROJECT_ID --only firestore:rules,firestore:indexes
```

Replace YOUR_FIREBASE_PROJECT_ID with the app's actual project ID. Publish these rules before using registration or signing in with the new version. These commands deploy only Firestore rules/indexes; no Functions or Storage deployment is needed. The app retains its original Firebase configuration. `flutter pub get` refreshes generated platform registrants after removing the photo packages.

## Community totals

Monthly participant-hours are computed on the device from the opportunity data already loaded by the feed. The calculation includes completed, non-cancelled shifts with valid start/end times and multiplies duration by registered attendee count. Cross-month shifts contribute only hours inside the current Gothenburg/Europe-Stockholm month. The app accounts for current European summer/winter time rules. Physical attendance is not verified because the app has no check-in system.

The existing 30-second display timer recomputes totals locally while the connected app is open. It performs no periodic Firestore queries or writes. Firestore listeners still incur their normal initial and changed-document reads, and ordinary sign-ups/posts use normal database writes.

The card now labels the account count **members**. A protected `communityStats/members` document is updated with an immutable `members/UID` marker in the same transaction as profile setup. Each authenticated account can count itself only once. Returning members cannot increment repeatedly; clients cannot edit arbitrary counts or list private member markers/profiles.

New registrations are counted immediately. Existing accounts enter the counter when they next sign in. To count all existing Authentication accounts immediately, optionally use the one-time administrator tool below. No automatic backend runs while the app is closed.

## Optional existing-member initialization/reconciliation

The app does not currently offer account deletion. Accounts removed directly in Firebase remain in the member counter until you run this optional local reconciliation. It uses the Admin SDK from your own computer and requires no deployed backend or Blaze plan. Its database reads/writes consume normal Firestore quota. It requires administrator credentials, which must stay on your computer and never be embedded in the Flutter app.

From my_app/tools, install the existing admin-tool dependencies with npm install. Configure Application Default Credentials for the intended Firebase project, then preview the changes:

```sh
node seed-member-count.mjs --project=YOUR_FIREBASE_PROJECT_ID
```

The default is read-only. To apply, temporarily pause account registrations and deletions, and supply a unique local backup filename:

```sh
node seed-member-count.mjs --project=YOUR_FIREBASE_PROJECT_ID --apply --maintenance-confirmed --backup=member-counter-backup.json
```

The tool backs up existing marker/count data, adds missing markers, removes markers for deleted Authentication accounts, and resets the counter to the current account total. It does not change private profiles, shifts, or memberships. Resume registrations after it completes. If interrupted, keep registrations paused and rerun with a new backup filename.

## Photos and earlier deployments

Photo uploads and network photo displays are removed. Event icons and member initials are used instead. Existing remote photo fields remain backwards-compatible in stored data but are not fetched; edited records clear them. firebase_storage and image_picker packages and their generated registrations have been removed. Map tiles remain part of the original map feature and are unrelated to Firebase Storage.

If you previously deployed the v2 Functions/Scheduler backend, removing its source from this ZIP does not stop that existing deployment. Delete the four refreshImpact functions and their Scheduler job in your Firebase/Google Cloud console before switching to Spark. If billing was previously enabled, switch the project to Spark in the Firebase console. This task did not deploy anything or change the project's actual billing plan.

## Validation

All 46 Dart source/test files passed syntax parsing. Node syntax checks passed for the one-time admin tool and updated Firestore rule-test script. Regression tests cover local hours, end boundaries, month rollover, absence of upload controls, levels, layout, mandatory end time, and protected member-counter behavior.

Flutter analysis/build/widget tests and Firebase emulator rules tests could not be executed in this environment. Syntax checks do not prove compilation or visual correctness. No live Firebase data or billing changes were made.
