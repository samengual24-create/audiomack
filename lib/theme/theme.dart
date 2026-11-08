import 'package:flutter/material.dart';

// Espaciados
class AppSpacing {
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing16 = 16;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
}

// Radios
class AppRadius {
  static const double radius8 = 8;
  static const double radius16 = 16;
}

// Tamaños de componentes
class AppSizes {
  static const double thumbnail = 48;
  static const double cardCover = 120;
  static const double cardCoverWide = 240;
  static const double cardCoverWideHeight = 140;
  static const double cardTextHeight = 64;
  static const double sectionHeight = 180;
  static const double navBarHeight = 72;
}

// Tipografía
class AppTypography {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral0,
  );

  static const TextStyle title1 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle title2 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral400,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle label2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

// Colores
class AppColors {
  static const primary50 = Color(0xFFF2EFFF);
  static const primary500 = Color(0xFF7C4DFF);
  static const primary600 = Color(0xFF6938E0);
  static const primary800 = Color(0xFF3E1F99);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral400 = Color(0xFF9E9E9E);
  static const neutral700 = Color(0xFF3A3A42);
  static const neutral800 = Color(0xFF2B2B31);
  static const neutral900 = Color(0xFF131317);
  static const neutral950 = Color(0xFF0B0B0D);

  static const discover500 = Color(0xFFEE7744);
  static const discover800 = Color(0xFFA8461E);
}

// Elevaciones
class AppElevation {
  static const double elevation0 = 0;
  static const double elevation2 = 2;
}

final ThemeData audioMack = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.neutral900,

  textTheme: const TextTheme(
    headlineLarge: AppTypography.headline1,
    headlineMedium: AppTypography.headline2,
    titleLarge: AppTypography.title1,
    titleMedium: AppTypography.title2,
    bodyLarge: AppTypography.body1,
    bodyMedium: AppTypography.body2,
    bodySmall: AppTypography.caption,
    labelLarge: AppTypography.button,
    labelMedium: AppTypography.label2,
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary500,
    onPrimary: AppColors.neutral0,
    primaryContainer: AppColors.primary800,
    onPrimaryContainer: AppColors.primary50,
    secondaryContainer: AppColors.neutral700,
    onSecondaryContainer: AppColors.neutral0,
    surface: AppColors.neutral900,
    onSurface: AppColors.neutral0,
    onSurfaceVariant: AppColors.neutral400,
    surfaceContainerLow: AppColors.neutral800,
    surfaceContainer: AppColors.neutral800,
    surfaceContainerHigh: AppColors.neutral800,
    surfaceContainerHighest: AppColors.neutral700,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.neutral900,
    surfaceTintColor: Colors.transparent,
    elevation: AppElevation.elevation0,
    centerTitle: false,
    titleTextStyle: AppTypography.headline2,
  ),

  tabBarTheme: const TabBarThemeData(
    labelColor: AppColors.neutral0,
    unselectedLabelColor: AppColors.neutral400,
    indicatorColor: AppColors.primary500,
    dividerColor: Colors.transparent,
    labelStyle: AppTypography.title2,
    unselectedLabelStyle: AppTypography.title2,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary500,
    foregroundColor: AppColors.neutral0,
    shape: CircleBorder(),
  ),

  navigationBarTheme: NavigationBarThemeData(
    height: AppSizes.navBarHeight,
    backgroundColor: AppColors.neutral950,
    surfaceTintColor: Colors.transparent,
    indicatorColor: Colors.transparent,
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary500);
        }
        return const IconThemeData(color: AppColors.neutral400);
      },
    ),
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.label2.copyWith(color: AppColors.primary500);
        }
        return AppTypography.label2.copyWith(color: AppColors.neutral400);
      },
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.neutral800,
    elevation: AppElevation.elevation2,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius16),
    ),
  ),
);