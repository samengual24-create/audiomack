import 'package:flutter/material.dart';

class AppSpacing {
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing16 = 16;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
}

class AppRadius {
  static const double radius8 = 8;
  static const double radius16 = 16;
}

class AppTypography {
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle label2 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}

class AppColors {
  static const primary50 = Color(0xFFF2EFFF);
  static const primary500 = Color(0xFF7C4DFF);
  static const primary600 = Color(0xFF6938E0);
  static const primary800 = Color(0xFF3E1F99);

  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral400 = Color(0xFF9E9E9E);
  static const neutral900 = Color(0xFF121212);
}

class AppElevation {
  static const double elevation0 = 0;
  static const double elevation2 = 2;
}

final ThemeData audioMack = ThemeData(
  useMaterial3: true,

  textTheme: const TextTheme(
    headlineLarge: AppTypography.headline1,
    labelLarge: AppTypography.label2,
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary500,
    onPrimary: AppColors.neutral0,
    primaryContainer: AppColors.primary800,
    onPrimaryContainer: AppColors.primary50,
  ),

  navigationBarTheme: NavigationBarThemeData(
    height: 72,
    backgroundColor: AppColors.neutral900,
    indicatorColor: AppColors.primary500,
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.neutral0);
        }
        return const IconThemeData(color: AppColors.neutral400);
      },
    ),
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return AppTypography.label2.copyWith(color: AppColors.neutral0);
        }
        return AppTypography.label2.copyWith(color: AppColors.neutral400);
      },
    ),
  ),

  cardTheme: const CardThemeData(
    elevation: AppElevation.elevation2,
  ),
);