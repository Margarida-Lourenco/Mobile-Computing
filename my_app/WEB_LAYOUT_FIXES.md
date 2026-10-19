# Web layout corrections — 19 October 2026

This archive includes all earlier requested features and the guest-photo update, plus fixes for the four reported web layout problems.

1. Navigation is anchored in Scaffold.bottomNavigationBar. The scaffold reserves its space outside the scrolling content and the navigation retains safe-area padding. All five destinations remain available.
2. The feed has bottom spacing within its scroll extent, above the reserved navigation area. The web page declares its viewport and uses the dynamic browser viewport height where supported. Tests check that the full last card clears navigation at phone and desktop sizes.
3. Opportunity sheets have a bounded height, rounded clipped surface, safe-area handling and a single scroll surface. Long location text wraps rather than overflowing. The posting form no longer nests a second scroll view inside the sheet. Final actions remain reachable with long content on short screens.
4. The sign-in header uses the same app background with no elevation tint. The form has a maximum width of 420 logical pixels, is centered horizontally and vertically in the available body, and can scroll when the keyboard is visible. Registration uses the same layout.

## Run this version

Extract the ZIP into a new folder. From Mobile-Computing-main/my_app run:

```powershell
flutter clean
flutter pub get
flutter run -d chrome
```

For a hosted web release, rebuild with flutter build web and deploy the new build/web output. Do not reuse an older build/web folder. Reload an already-open app after rebuilding; if it still displays the old layout, clear its cached site data or use a fresh browser tab/profile.

These corrections are in the app source and require rebuilding. Firebase rules, demo accounts, listings and the previously deployed Supabase guest-photo service were not changed during this correction.

## Validation

- Full Flutter suite: 62 tests passed, including 7 new layout regressions.
- Flutter static analysis: no issues.
- Release web build: successful.
- New checks cover 320×568, 390×640, 390×740 and 1366×768 layouts, the navigation bounds, full visibility of the last card, long details and address text, centered authentication layout and keyboard scrolling.
- Flutter-rendered previews with loaded Arial and Material Icons fonts were inspected. Previews use sample listings rather than a live signed-in session.
- The local web preview could not be reached by the available browser session, so no live browser interaction claim is made for this correction.

Preview images are in my_app/review:

- web-navigation-fixed.png: feed scrolled to its end, with all navigation buttons visible.
- web-details-fixed.png: correctly sized opportunity details sheet.
- web-sign-in-mobile.png: centered mobile sign-in layout.
- web-sign-in-desktop.png: centered desktop sign-in layout.
