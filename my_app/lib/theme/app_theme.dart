import 'package:flutter/material.dart';

// EDIT THIS FILE to customize the app. Screens reference these shared tokens.
// Colors: AppColors. Fonts: AppFonts. Text presets: AppTextStyles.
// Corners: AppRadii. Theme/button/input/card defaults: AppTheme below.
class AppFonts {
  static const family = 'Arial';
  static const caption = 12.0;
  static const body = 14.0;
  static const bodyLarge = 16.0;
  static const subtitle = 18.0;
  static const section = 20.0;
  static const hero = 22.0;
  static const page = 24.0;
  static const header = 25.0;
  static const sheet = 26.0;
  static const brand = 28.0;
  static const medium = FontWeight.w700;
  static const bold = FontWeight.w800;
  static const heavy = FontWeight.w900;
}

class AppColors {
  static const error = Color(0xFFB3261E);
  static const white = Colors.white;
  static const transparent = Colors.transparent;
  static const grey = Colors.grey;
  static const inactiveIcon = Color(0xFF91A4AF);
  static const progressTrack = Color(0xFFE8F7E3);
  static const sheetHandle = Color(0xFFC2D8E5);
  static const chipBorder = Color(0xFFCDDfea);
  static const cardShadow = Color(0x0808344C);
  static const navy = Color(0xFF08344C);
  static const blue = Color(0xFF8FD2EE);
  static const darkBlue = Color(0xFF2F7898);
  static const green = Color(0xFFB6E5A6);
  static const paleGreen = Color(0xFFD7F1CE);
  static const paleBlue = Color(0xFFE8F2F8);
  static const muted = Color(0xFF526979);
  static const border = Color(0xFFD5E4ED);
  static const background = Color(0xFFF9FCFD);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
      fontFamily: AppFonts.family,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: AppFonts.body),
        bodyLarge: TextStyle(fontSize: AppFonts.bodyLarge),
        labelLarge: TextStyle(fontSize: AppFonts.body),
        bodySmall: TextStyle(fontSize: AppFonts.caption),
        labelSmall: TextStyle(fontSize: AppFonts.caption),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.r13),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

BoxDecoration appCardDecoration() {
  return BoxDecoration(
    color: AppColors.white,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(AppRadii.r18),
    boxShadow: const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 18,
        offset: Offset(0, 5),
      ),
    ],
  );
}

class AppTextStyles {
  static const formError =
      TextStyle(color: AppColors.error, fontSize: AppFonts.body);
  static const brandTitle =
      TextStyle(fontSize: AppFonts.brand, fontWeight: AppFonts.bold);
  static const captionAccentBold = TextStyle(
      fontSize: AppFonts.caption,
      fontWeight: AppFonts.bold,
      color: AppColors.darkBlue);
  static const heroTitle = TextStyle(
      fontSize: AppFonts.hero,
      fontWeight: AppFonts.heavy,
      color: AppColors.navy);
  static const captionMuted =
      TextStyle(fontSize: AppFonts.caption, color: AppColors.muted);
  static const actionLabel =
      TextStyle(fontWeight: AppFonts.bold, color: AppColors.navy);
  static const captionBold =
      TextStyle(fontSize: AppFonts.caption, fontWeight: AppFonts.bold);
  static const pageTitle =
      TextStyle(fontSize: AppFonts.page, fontWeight: AppFonts.bold);
  static const bodyMuted = TextStyle(color: AppColors.muted);
  static const captionNavy =
      TextStyle(fontSize: AppFonts.caption, color: AppColors.navy);
  static const avatarInitials =
      TextStyle(color: AppColors.navy, fontWeight: AppFonts.heavy);
  static const profileTitle =
      TextStyle(fontSize: AppFonts.subtitle, fontWeight: AppFonts.heavy);

  static const bodyBold = TextStyle(fontWeight: AppFonts.bold);
  static const calendarDay =
      TextStyle(fontSize: AppFonts.bodyLarge, fontWeight: AppFonts.heavy);
  static const statValue =
      TextStyle(fontSize: AppFonts.section, fontWeight: AppFonts.heavy);

  static const greeting =
      TextStyle(fontSize: AppFonts.header, fontWeight: AppFonts.heavy);
  static const cardKicker = TextStyle(
      fontSize: AppFonts.caption,
      color: AppColors.muted,
      fontWeight: AppFonts.bold,
      letterSpacing: .4);
  static const cardTitle =
      TextStyle(fontSize: AppFonts.body, fontWeight: AppFonts.bold);
  static const sectionKicker = TextStyle(
      fontSize: AppFonts.caption,
      color: AppColors.darkBlue,
      fontWeight: AppFonts.bold,
      letterSpacing: 1.2);
  static const smallKicker = TextStyle(
      fontSize: AppFonts.caption,
      color: AppColors.darkBlue,
      fontWeight: AppFonts.heavy,
      letterSpacing: 1.1);
  static const sheetTitle =
      TextStyle(fontSize: AppFonts.sheet, fontWeight: AppFonts.bold);
  static const caption = TextStyle(fontSize: AppFonts.caption);
  static const compactSheetTitle =
      TextStyle(fontSize: AppFonts.header, fontWeight: AppFonts.bold);
  static const bodyMedium = TextStyle(fontWeight: AppFonts.medium);
  static const captionMutedBold = TextStyle(
      fontSize: AppFonts.caption,
      color: AppColors.muted,
      fontWeight: AppFonts.bold);
  static const eventTitle =
      TextStyle(fontSize: AppFonts.sheet, fontWeight: AppFonts.heavy);
  static const description = TextStyle(color: AppColors.muted, height: 1.45);
}

class AppRadii {
  static const r4 = 4.0;
  static const r5 = 5.0;
  static const r10 = 10.0;
  static const r12 = 12.0;
  static const r13 = 13.0;
  static const r15 = 15.0;
  static const r17 = 17.0;
  static const r18 = 18.0;
  static const r20 = 20.0;
  static const r24 = 24.0;
  static const r28 = 28.0;
}

// Shared padding values and icon sizes. Geometry of maps stays in map code.
class AppSpacing {
  static const s2 = 2.0;
  static const s5 = 5.0;
  static const s6 = 6.0;
  static const s7 = 7.0;
  static const s8 = 8.0;
  static const s9 = 9.0;
  static const s10 = 10.0;
  static const s12 = 12.0;
  static const s13 = 13.0;
  static const s14 = 14.0;
  static const s15 = 15.0;
  static const s16 = 16.0;
  static const s17 = 17.0;
  static const s20 = 20.0;
  static const s21 = 21.0;
  static const s24 = 24.0;
  static const s25 = 25.0;
  static const s28 = 28.0;
  static const s100 = 100.0;
}

class AppIconSizes {
  static const s13 = 13.0;
  static const s14 = 14.0;
  static const s16 = 16.0;
  static const s17 = 17.0;
  static const s18 = 18.0;
  static const s19 = 19.0;
  static const s34 = 34.0;
  static const s42 = 42.0;
  static const s44 = 44.0;
  static const s46 = 46.0;
  static const s48 = 48.0;
  static const s58 = 58.0;
  static const s150 = 150.0;
}

class AppIcons {
  static const badge = Icons.workspace_premium_outlined;
}
