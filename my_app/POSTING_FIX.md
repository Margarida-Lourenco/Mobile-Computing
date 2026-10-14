> This is the Spark edition. Follow [SPARK_SETUP.md](SPARK_SETUP.md) for current setup and validation. Any photo-upload, Storage or Functions instructions below describe older versions.

# Posting feedback fix

The previous form could keep accepting taps without showing a visible explanation. Missing-details warnings used a snackbar behind the bottom sheet, and backend errors were displayed above the form rather than beside the Publish button.

This version displays the exact missing details directly above Publish, scrolls the explanation into view, shows Saving… while a write is pending, disables duplicate submission, and displays failed-save errors beside the button. After ten seconds of waiting it explains that Firebase is still processing the save. Existing entered details remain available for retry after a failed save.

Required: title, Host, location text, description, date, start time, positive volunteer count and a confirmed map pin. Use Place map pin, choose a point, then Use this location. The cover photo is optional; leave it unselected on Spark.

Firebase configuration and all five earlier changes are retained. This fix does not change Firestore rules, so no new rules deployment is needed if you already published the username-enabled rules from the previous update.

Extract this ZIP in a new folder, open Mobile-Computing-main/my_app, run flutter pub get and flutter run. When testing, stop the previous app run and start the new folder so you are running this version. If posting still fails, share the new visible message.

Live cloud writes have not been tested against your Firebase project. Tests use controlled save callbacks to verify validation, pending/successful saves and failure/retry behavior.
