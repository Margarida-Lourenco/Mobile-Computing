Validation of Mobile-Computing-main (2).zip update — 2026-10-07

- All five requested app changes and the posting-feedback fix are included.
- Original Firebase options, google-services.json and Android Firebase build configuration were preserved byte for byte.
- dart format lib test: 35 Dart files formatted.
- flutter analyze --no-pub: No issues found.
- flutter test --no-pub: All 15 tests passed.
- Added posting tests verify visible validation, successful save/close, duplicate prevention and failure/retry.
- Checks cover username validation and registration form, username/legacy greetings, one-second confirmation dismissal, profile error recovery, Firestore serialization and existing UI/map interactions.
- Firebase cloud operations and updated rules were not tested against the live project. Publish the updated Firestore rules before registering accounts with usernames.
- Dependency resolution succeeded but Flutter reported Windows Developer Mode is required for native plugin symlinks. Analysis and tests ran successfully; no APK/IPA release build was produced.
