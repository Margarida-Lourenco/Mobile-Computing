# Change the app appearance

Open `lib/theme/app_theme.dart`. All custom colors, font sizes, weights, text presets, corner radii, padding and icon-size values are defined here. Screens/widgets use these constants; map coordinates and interaction logic remain in their original files.

| What you want to change | Where to edit |
|---|---|
| Main text and heading color | AppColors.navy |
| Button/accent color | AppColors.darkBlue and the AppTheme colorScheme seed |
| Green accents | AppColors.green and AppColors.paleGreen |
| Background | AppColors.background |
| Card/input surfaces | AppColors.white |
| Small text | AppFonts.caption |
| Normal body text | AppFonts.body |
| Headings | AppFonts.page, header, sheet, brand |
| Font family | AppFonts.family (add a font asset to pubspec.yaml if using a custom font) |
| Text weight | AppFonts.medium, bold, heavy |
| Specific text appearances | AppTextStyles (e.g. greeting, cardTitle, sectionKicker) |
| Rounded corners | AppRadii; r18 is the original 18-pixel radius shared by cards |
| Padding | AppSpacing; s20 is the original shared 20-pixel padding |
| Icon sizes | AppIconSizes |
| Medal symbol | AppIcons.badge |
| Default button/input styles and text theme | AppTheme.light |
| Card border/shadow | appCardDecoration() |

The numbers in constant names describe the original defaults. For example, changing AppRadii.r18 to 22 makes all corners referring to r18 rounder. Edit one shared token to update its uses across the app. Layout-specific dimensions (map height, image height, calendar width, spacing between elements) remain beside the widgets that use them.

Use Flutter hot reload to see changes. A font-family or initialization change may need a hot restart.
