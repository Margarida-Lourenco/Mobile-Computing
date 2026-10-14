# Spark edition

All earlier requested UI changes are retained: full-width green card, sign-out at the bottom of My Page, always-visible single-line navigation labels, past shifts excluded from discovery/map and available beside Calendar, My shifts activity counts, and level-one initialization with progress from valid completed shifts. End time remains mandatory.

Removed Cloud Functions and Scheduler source/configuration and all Firebase Storage/photo-upload flows and dependencies. Community hours now calculate locally from the existing event stream. Account counting uses a rules-protected, idempotent membership transaction, with an optional local tool to initialize existing accounts or reconcile deletions. Profile initials and event icons replace remote photos.

Publish the updated Firestore rules before signing in or registering. Existing accounts are counted on their next login unless the optional initialization tool is run. See my_app/SPARK_SETUP.md.

Verification: 46 Dart files passed Tree-sitter syntax parsing. Node syntax checks passed for the admin script and rule-test script. No Flutter build/widget tests or emulator rule tests were executed successfully. No live deployment, data migration or billing changes occurred.
