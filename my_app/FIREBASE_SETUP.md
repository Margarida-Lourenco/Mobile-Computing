# Connect Göod Together to your Firebase project

This update preserves the Firebase configuration supplied in Mobile-Computing-main (2).zip, including lib/firebase_options.dart and android/app/google-services.json. The setup steps below are only needed when connecting another project or adding a platform. The app starts in labelled preview mode, with the original sample opportunities and working map, if configuration is missing or initialization fails. Preview edits are temporary; Firebase mutations require a signed-in account.

## 1. Firebase Console

1. Create or select your project at https://console.firebase.google.com/.
2. Authentication > Get started > Sign-in method > Email/Password: enable Email/Password (email link sign-in is not needed).
3. Firestore Database > Create database: select a suitable region and production mode. This app uses the `(default)` database.
4. Storage > Get started: create the default bucket and select a region. Firebase currently requires the Blaze billing plan for Cloud Storage. Set billing budget alerts in Google Cloud; alerts are not spending caps. See https://firebase.google.com/docs/storage/flutter/start.
5. Do not use public test-mode rules. The supplied rules permit signed-in reads of events/images, owner-only event edits/deletes, and private user profiles/membership collections.

## 2. Configure FlutterFire

Install Flutter and Node.js, then run these commands in `Mobile-Computing-main/my_app`:

```sh
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutter pub get
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID --platforms=android,ios,web
```

Replace YOUR_FIREBASE_PROJECT_ID with your actual Firebase project ID. Select only the platforms you intend to run; add macOS/Windows if needed and supported by your FlutterFire tools. Linux Firebase support is limited; the target is the original mobile app.

`flutterfire configure` replaces `lib/firebase_options.dart` with real FirebaseOptions for your platforms and creates any required platform configuration files. Do not manually fill the placeholder with guessed credentials. Re-run configuration after changing platforms or Firebase products. On Android this project uses application ID `se.goodtogether.app`; let FlutterFire match this ID. Use the existing Xcode bundle identifier for iOS or change it deliberately before registering. If native files are needed, obtain `google-services.json` and `GoogleService-Info.plist` from your own registered apps and follow the CLI output. Do not reuse files belonging to another project.

Official setup: https://firebase.google.com/docs/flutter/setup.

## 3. Deploy rules

The ZIP already contains firebase.json, firestore.rules, firestore.indexes.json and storage.rules. From the same directory:

```sh
firebase deploy --project=YOUR_FIREBASE_PROJECT_ID --only firestore:rules,firestore:indexes,storage
```

Alternatively paste the supplied rules into Firestore > Rules and Storage > Rules and Publish both. No composite indexes are required by the current queries. Storage images are under `profile_images/{uid}/{version}` and `event_images/{uid}/{eventId}/{version}`; using the UID in the path allows the cover to upload before the event document exists. Files are limited to images smaller than 5 MB. These are example rules for this app's current schema; test them in the Emulator Suite before production.

## 4. Run and check

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

On Windows enable Settings > System > For developers > Developer Mode when Flutter reports that plugin symlinks are unavailable. iOS builds require macOS/Xcode; update native minimum deployment targets if your installed Firebase SDK asks for a newer target. Gallery permission text is included for iOS, and macOS selected-file/network entitlements are included. The picker currently selects existing images rather than using the camera.

Create two accounts. With account A: edit name/location/photo; create an event with a date/time, cover and map pin; favorite/join it; restart and verify persistence. Check Discover, Map and My Page. With account B verify the event is visible but Edit/Delete are absent; A can edit/delete it. Test loss of network and rules-denied writes: the forms retain input and display errors. A live Firebase test cannot be performed until your own project is configured.

## Data and behavior

- `users/{uid}` stores name, location and profileImageUrl.
- `users/{uid}/favorites/{eventId}` and `joined/{eventId}` store membership and server timestamps. Joined is a personal commitment; this version does not enforce capacity or decrement the volunteer count.
- `opportunities/{eventId}` stores ownerId, metadata, coordinates, startsAt, coverImageUrl, imageUrls, createdAt and updatedAt. String IDs match Firestore document IDs. Posted events are derived from ownerId; Discover and Map use the same live stream.
- One cover image is displayed. `imageUrls` provides the gallery extension point; increase the rule list limit and add a multi-image editor when implementing galleries.
- Profile/event photos upload before the Firestore write. Failed writes attempt to remove the new upload. Replaced/deleted photos have best-effort cleanup after successful commits. Interrupted uploads and cleanup failures may leave orphan files: use an administrative cleanup job for production.
- Deleting events leaves other users' private membership references; UI lists/counts ignore missing events. An administrative cleanup function can remove stale references.
- Firebase download URLs are bearer links. Treat photos as shareable content; do not use these URLs for confidential media.
- Original rewards, badges, invite UI and city impact totals remain presentation/demo features, not a verified rewards backend. The map and location picker implementation are unchanged.
- All signed-in users load the current events collection. Add pagination/geographic queries when the dataset grows.
