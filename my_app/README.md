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
│   └── my_page_screen.dart
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

`HomeShell` owns the app's temporary UI state and coordinates the screens.

Screens are responsible for page layouts.

Widgets are reusable UI components.

Sheets contain modal flows such as posting, inviting, rewards, area selection,
and opportunity details.

The app currently uses local sample data. It is ready to connect to a backend
later without putting API code directly into the UI widgets.
