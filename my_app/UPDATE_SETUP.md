# Install the events and notifications update

Your supplied Firebase configuration is already preserved in this ZIP. You do not need to create a new project or run flutterfire configure again.

## What changed

- Remaining places update atomically when users join or leave; full events cannot be overbooked. Hosts can open their event and choose View participants to see usernames.
- Notifications sits between Post and My Page, with an unread badge. It records your joins/leaves, signups/withdrawals on your events, and event cancellations. These are in-app notifications, visible when you open the app, rather than phone push messages.
- Posts have an optional end time, later than the start time on the same day.
- My Page has distinct activity category buttons and separate Agenda/Calendar controls, sized for narrow phones.
- Calendar dates with joined events have a green marker; selecting a date displays its events. Agenda displays all your joined events.
- Cover photos can be changed or removed before publishing and when editing your own event.
- The posting form now says Address.

## Before opening the updated app

1. Close the old app on all devices while updating. Extract this ZIP into a new folder. Keep your current folder as a backup.
2. If anyone has already joined an event, follow the migration instructions below once. This transfers existing private signup records into the host-visible participant lists and calculates occupied places. If there are no existing signups, skip this step.
3. In Firebase Console, open your existing project, then Firestore Database → Rules. Open the ZIP's `my_app/firestore.rules` in a text editor, copy its entire contents into the Rules editor, and click Publish. This is required: the old rules do not support the new atomic signup and notification writes.
4. Open a terminal in the new `Mobile-Computing-main/my_app` folder. Run `flutter pub get`, then `flutter run`. Fully restart the app; hot reload is insufficient for switching project folders.
5. Test with two accounts: one posts an event with two places; the other joins. The remaining places should become one, the host should see the username under View participants, and both accounts should receive a notification. Leaving restores the place.

## Transfer existing signups (only needed once)

This administrative tool is included because the earlier app stored signups privately under each user. It cannot recover names into host lists using normal app permissions. It uses your own project access and does not require Cloud Functions.

1. Install Node.js if `node --version` does not work.
2. Firebase Console → Project settings → Service accounts → Generate new private key. Save it in a private folder outside the app project. Never share or include this key in a ZIP or source control: it grants administrative access.
3. Find your Project ID under Project settings → General. Use the exact ID, not the display name.
4. Open PowerShell in the extracted app's `tools` folder. Replace both placeholders below with your own values:

```powershell
npm install
$env:GOOGLE_APPLICATION_CREDENTIALS = 'C:\private\your-service-account-key.json'
node migrate-attendance.mjs --project YOUR_PROJECT_ID
```

This first run only reports planned changes. It does not change the database.

5. With all old app instances still closed, apply the transfer and save a backup:

```powershell
node migrate-attendance.mjs --project YOUR_PROJECT_ID --apply --backup attendance-backup.json
```

Keep that backup privately. The tool preserves event dates/photos and signup times; legacy usernames fall back to the saved profile name. If old signups exceeded capacity, capacity increases to accommodate everyone. No retrospective notifications are created. The tool refuses to overwrite an existing backup filename.

6. Publish the updated rules and launch the new app as described above. All users should switch to the updated version.
7. Remove the downloaded private key when finished and delete/revoke that key in Google Cloud IAM → Service accounts → your service account → Keys. Clear the terminal credential setting:

```powershell
Remove-Item Env:GOOGLE_APPLICATION_CREDENTIALS
```

If you need to undo the migration before using the updated app, with apps closed and your private credential still configured:

```powershell
node migrate-attendance.mjs --project YOUR_PROJECT_ID --restore attendance-backup.json --apply
```

Restoring replaces the backed-up records, so do not use it after new signups have occurred.

## Cost and behavior

No paid Cloud Functions or push notification service was added. These features use Authentication and Firestore, subject to your existing plan's quotas. Existing Firebase Storage photo uploads still require the Firebase billing setup described in FIREBASE_SETUP.md; joining and posting without photos do not require enabling Storage.

Cancelling an event preserves its record and participant list for host review and sends cancellation notices. It disappears from Discover, Map, and volunteers' calendars. The host retains the cancelled event in Posted and can retry cancellation notifications if a connection interrupted delivery.

## Validation

25 Flutter tests passed, including map interactions, posting validation, image removal/end time, calendar markers and narrow screens. Flutter static analysis passed. 22 local Firestore emulator checks passed, including competing last-place signups, ownership/privacy, atomic receipts, withdrawal and cancellation. Migration dry run, apply, repeated apply, timestamp preservation and backup restore passed against the emulator. No changes were made to your live Firebase project during these checks.
