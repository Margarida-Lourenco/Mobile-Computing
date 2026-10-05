# Göod Together - Flutter

This is the refactored Flutter version of the Figma Make volunteering app.

## Project structure

```text
lib/
├── main.dart
├── data/
│   └── sample_opportunities.dart
├── models/
│   └── opportunity.dart
├── theme/
│   └── app_theme.dart
├── screens/
│   ├── home_shell.dart
│   ├── discover_screen.dart
│   ├── map_screen.dart
│   ├── my_page_screen.dart
│   ├── edit_info_screen.dart
│   └── pick_location_screen.dart
└── widgets/
    ├── app_sheet.dart
    ├── bottom_nav.dart
    ├── category_chips.dart
    ├── empty_state.dart
    ├── header.dart
    ├── icon_box.dart
    ├── opportunity_card.dart
    ├── search_box.dart
    ├── section_title.dart
    ├── small_kicker.dart
    └── sheets/
        ├── area_picker_sheet.dart
        ├── invite_sheet.dart
        ├── opportunity_details_sheet.dart
        ├── post_opportunity_sheet.dart
        └── rewards_sheet.dart
```

## Run

```bash
flutter pub get
flutter run
```

## Architecture

`HomeShell` owns the app's opportunity UI state and coordinates the screens. Profile name and location are saved locally on the device.

Screens are responsible for page layouts.

Widgets are reusable UI components.

Sheets contain modal flows such as posting, inviting, rewards, area selection,
and opportunity details.

The map uses OpenStreetMap tiles and needs an internet connection. The location button asks for device location permission only when tapped. Sample opportunities have map coordinates; publishing a new one now requires selecting a meeting-point pin. Before a public launch, check the [OpenStreetMap tile usage policy](https://operations.osmfoundation.org/policies/tiles) and arrange a suitable tile provider if traffic grows.

The app currently uses local sample data. It is ready to connect to a backend
later without putting API code directly into the UI widgets.
