# Guest listing photos — follow-up update

Guest listing-photo access is implemented in the Flutter app and deployed to the existing Supabase photo-api function.

Use the new Mobile-Computing-guest-photos.zip instead of the earlier ZIP, then rebuild/run the app as usual. The earlier app version blocks guest photo requests locally, so deploying the backend alone is insufficient.

- Guests can view event/listing photos without logging in. Both storage buckets remain private; the photo API issues an expiring signed link for an event-image reference.
- Profile photos still require a verified Firebase session.
- Uploads still require a verified Firebase session; deletion also requires ownership.
- Images are cached in the app to avoid repeat photo API calls.
- Existing listing photos work without re-uploading. No listing data or demo accounts were changed.

Verification for this follow-up:

- Flutter photo tests: 8 passed (including 3 new regressions for guest reads, private profile cache protection, and denied guest requests).
- Photo API security tests: 7 passed.
- Flutter static analysis: no issues.
- Live existing listing image: guest signed-link request succeeded and the image returned HTTP 200, image/webp.
- Live guest profile read, upload and deletion requests: HTTP 401 as expected.

The prior full app validation (52 Flutter tests, 37 Firestore checks and successful web build) is documented in VALIDATION.md. This follow-up was checked with the targeted photo tests and static analysis.

No billing plan upgrade or public-bucket setting was needed.
