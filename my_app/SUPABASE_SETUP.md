# Supabase photos: finish setup

The current app has already been updated in your existing my_app folder. Keep Firebase Authentication and Firestore on Spark. Images use your Supabase Free project and the two private buckets you created.

Project: https://zblkhkgpmbgwvcrbhokw.supabase.co
Function name: photo-api
Firebase project: cls055-26-project

## 1. Confirm bucket settings

In Supabase, open SQL Editor, create a new query, paste the contents of `supabase/storage-setup.sql`, and run it. This configures profile-images and event-images as private, limits each file to 5 MB, and allows JPEG, PNG and WebP images. Existing files are retained.

Do not add anonymous upload/delete policies. This implementation authorizes requests inside the function. If you previously created broad Storage policies, review/remove those policies for these two buckets before testing.

## 2. Deploy the prepared Supabase function once

Open PowerShell in your existing my_app folder and run:

```powershell
npx.cmd supabase login
npx.cmd supabase functions deploy photo-api --project-ref zblkhkgpmbgwvcrbhokw --no-verify-jwt --use-api
```

Follow the browser login prompts using the Supabase account that owns this project. If npx asks to install the Supabase CLI package, accept. The --use-api option bundles on Supabase, so Docker is not required. GitHub connection alone does not perform this function deployment.

The --no-verify-jwt flag is intentional: Supabase's gateway must not demand a Supabase Auth token. The prepared function instead verifies the actual Firebase token's RS256 signature using Google's signing keys, validates the exact Firebase project issuer/audience and expiration, and rejects unsigned, wrong-project and expired tokens. Do not replace this function with a generic public upload endpoint.

Supabase normally supplies server credentials automatically to the deployed function via SUPABASE_SECRET_KEYS or SUPABASE_SERVICE_ROLE_KEY. No secret key belongs in the Flutter app, GitHub, or this chat. The provided publishable key is the only Supabase key included in app source. No Firebase Admin key, Firebase custom claims, Firebase Cloud Functions, or second user login is needed.

## 3. Rebuild the Flutter app

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```

Fully stop any previously running app first. flutter pub get must finish successfully so the image-picker platform plugins are regenerated. Dependency resolution succeeded in the agent's validation copy, but final plugin generation was blocked by its access restrictions to the pub-cache index, so this command still needs to run on your machine.

## 4. Test uploads

- Sign in with an existing Firebase account.
- My Page > Edit info > Choose profile picture > Save changes. Your photo should appear on My Page.
- Post an opportunity, select Choose event cover photo, fill in the required start/end times and other fields, and publish. Check its photo in the feed and details.
- Edit a photo or choose Remove photo, save, restart the app and verify the result persists.
- In Supabase Storage, files should be in a folder named after the Firebase user ID. Buckets stay private. Viewing links are temporary and work for up to one hour; the app caches them for fifty minutes and requests fresh links when needed.

Photos are intended to be visible to signed-in members. Any valid Firebase member of this app can request a viewing link; users can upload/delete only their own files. An issued signed link remains usable until it expires, even after sign-out. Firestore stores stable supabase:// references rather than expiring download URLs.

Replacing/removing photos updates Firestore first, then attempts to delete the old object. Failed Firestore saves attempt to delete the new upload and retain the previous photo. Cleanup failures do not turn a successful save into an error; stale/orphaned files may occasionally require manual cleanup. Old Firebase Storage image URLs are not reused; upload those photos again through the new controls.

## Troubleshooting

- "Photo service is not available yet": check deployment succeeded in the correct project and that the function name is photo-api.
- "Please sign in again": sign out/in and check the function's Firebase project ID matches lib/firebase_options.dart.
- Upload failed: inspect Supabase > Edge Functions > photo-api > Logs, and confirm the buckets and size/MIME settings above. Do not paste tokens or secret keys when sharing logs.
- "Photo service is not configured": verify the hosted function has its default Supabase server credentials. If your project has disabled the legacy service-role credential and has no default secret key, configure a default server secret through Supabase's dashboard; never put it in client code.

## Validation and free-plan behavior

Six executable server-side security tests passed (path/bucket validation, owner-only deletion, required Firebase claims, image signatures, upload sizes and streamed-body limits). Node syntax checking passed for the TypeScript function entry point. Dart analysis of lib and test completed without diagnostics. Added Flutter photo-client regression tests for token headers, binary uploads, caching, refresh, missing deployment and signed-out rejection. Those Flutter tests were not executed successfully here because this environment blocks the test runner's loopback socket connection. No live upload or production function deployment has been performed by the agent.

Firebase remains on Spark; Supabase storage, bandwidth and Edge Function invocations consume its Free plan allowances. Small compressed images help keep usage down. There is no scheduled upload/backend polling job. No billing settings were changed.

Official references: [Deploy functions](https://supabase.com/docs/guides/functions/deploy), [Server environment variables](https://supabase.com/docs/guides/functions/secrets), [Firebase ID-token verification](https://firebase.google.com/docs/auth/admin/verify-id-tokens#verify_id_tokens_using_a_third-party_jwt_library).
