# Requested community data

Created and verified in Firebase project `cls055-26-project` on 21 October 2026: 46 Authentication accounts, 94 opportunities, and 552 app documents. Member markers and sample sign-ins were verified. Existing unrelated records were preserved.

The dataset contains 46 accounts (42 people and four organisations), 94 distinct opportunities, and 103 attendance records. Each account hosts 1–3 opportunities. Each person has 0–2 past participations and 0–3 future sign-ups. All eight app categories are represented. Activities run from 12 October through 25 December 2026, in Europe/Stockholm time. The duplicate Astrid was split into Astrid and Astrid Berg, as requested.

All names in the app match the supplied list, apart from the authorised surname for the second Astrid. Generated `example.com` email addresses are demo sign-in IDs, not contact addresses. No email is sent when these accounts are created.

Every opportunity has a unique title and distinct coordinates. Pins are approximate neighbourhood meeting points; exact private homes and organisation branches are not asserted. The listings explain that hosts will confirm meeting details. Older characters' posts mainly request physical help. The four organisations host activities relevant to their stated purpose.

## Validate without accessing Firebase

From this `tools` directory:

```powershell
npm install
node seed-requested-community.mjs
node --test seed-requested-community.test.mjs
```

The validation run performs no Firebase access and creates no accounts. Eight tests cover the baseline dataset, supplied volunteer counts, and rejection of duplicate pins/titles, missing categories, overbooking, excessive capacity and self-sign-ups.

## Import after renewing the administrator login

```powershell
firebase login --reauth
$cliLib = Join-Path $env:APPDATA 'npm\node_modules\firebase-tools\lib'
node seed-requested-community.mjs --apply "--firebase-cli-lib=$cliLib" --credentials=../../../community-demo-logins.json --report=../../../community-import-report.json
```

The project is fixed to `cls055-26-project`, matching this app's Firebase configuration. Application Default Credentials may be used instead by omitting `--firebase-cli-lib` when already configured.

The importer checks collisions and existing documents before creating anything. New records use the `gt-requested-20261021` namespace. It preserves existing unrelated accounts and events and refuses to replace edited seed records. Each event and its attendance/notification records are committed together. A retry uses the same saved login file and does not duplicate successfully created records.

Random passwords are written to the login file before Auth creation, so they remain available even if an import is interrupted. Keep that file for signing in and retrying. It is not included in the source archive. No passwords or administrator tokens are printed by the importer.

Profiles, posts, participant lists, private sign-ups, in-app notifications and member registry entries are populated. Reward levels and contribution hours are calculated by the app from ended joined opportunities. The member counter is incremented once for each newly registered member, preserving concurrent registrations.

The importer reads back and verifies every seeded document and all 46 Auth accounts before writing its success report. It does not deploy application code or Firestore rules. The previous app delivery's rules support `Other`; deploy them separately if they have not yet been installed.

## Photos added

All 46 profiles and 94 opportunity covers now have web-sourced stock images uploaded through the existing authenticated photo service. Each stable Supabase reference and signed image load was verified. Covers were also read without Firebase authentication to check guest browsing. The current dataset includes the stable photo references; images live in the existing Supabase project and are not embedded in this ZIP.

See PHOTO_CREDITS.md and COMMUNITY_PHOTO_REPORT.json at the project root for source links, photographer credits, record references and verification details. Stock portraits represent the demo accounts; organisation pictures are illustrative rather than official branding. No real organisation branch or named person is identified by these pictures.
