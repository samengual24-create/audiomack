import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

// Espaciados
class AppSpacing {
  static const double spacing4 = 4;
  static const double spacing8 = 8;
  static const double spacing16 = 16;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
}

// Formas (corner radius 50 a 600 de la guía de estilos)
class AppRadius {
  static const double radius0 = 0; // corner-radius-50
  static const double radius4 = 4; // corner-radius-100
  static const double radius8 = 8; // corner-radius-200
  static const double radius12 = 12; // corner-radius-300
  static const double radius16 = 16; // corner-radius-400
  static const double radius24 = 24; // corner-radius-500
  static const double radius32 = 32; // corner-radius-600
  static const double radiusFull = 999; // avatares circulares
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

  // Avatares (circle-avatar sm, md y lg)
  static const double avatarSm = 44;
  static const double avatarMd = 64;
  static const double avatarLg = 104;
}

// Tipografía: familia Lexend
class AppTypography {
  // Headers
  static const TextStyle headline1 =
      TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.neutral0,
  );
  static const TextStyle headline3 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle headline4 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle headline5 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  // Subtitles
  static const TextStyle subtitle1 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const TextStyle subtitle2 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  // Bodies
  static const TextStyle body1 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const TextStyle body2 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400);

  // Texto secundario bajo títulos de canciones
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral300,
  );

  // Button
  static const TextStyle button =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  // Overline
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  // Etiquetas de la barra de navegación
  static const TextStyle label2 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
}

// Colores
class AppColors {
  // Primario (la escala es la misma que la del secundario)
  static const primary50 = Color(0xFFF2EFFF);
  static const primary100 = Color(0xFFE3DEFF);
  static const primary200 = Color(0xFFC7BDFF);
  static const primary300 = Color(0xFFAFA0FF);
  static const primary400 = Color(0xFF8B7BFA);
  static const primary500 = Color(0xFF765FFF); // base
  static const primary600 = Color(0xFF5B3FE8);
  static const primary700 = Color(0xFF4733BC);
  static const primary800 = Color(0xFF33279A);
  static const primary900 = Color(0xFF1B1272); // base del secundario

  // Neutros
  static const neutral0 = Color(0xFFFFFFFF);
  static const neutral50 = Color(0xFFF5F5F6);
  static const neutral100 = Color(0xFFE8E8EA);
  static const neutral200 = Color(0xFFC9C9CE);
  static const neutral300 = Color(0xFF9A9AA0);
  static const neutral400 = Color(0xFF70707A);
  static const neutral500 = Color(0xFF4A4A52);
  static const neutral600 = Color(0xFF2B2B31);
  static const neutral700 = Color(0xFF1C1C22);
  static const neutral800 = Color(0xFF131317); // base
  static const neutral900 = Color(0xFF0B0B0D);

  // Acento temporal: Echo (pasado)
  static const echo50 = Color(0xFFFBF1EC);
  static const echo200 = Color(0xFFF4C2AA);
  static const echo500 = Color(0xFFEE7744); // base
  static const echo800 = Color(0xFF8B3718);

  // Acento temporal: Pulse (presente)
  static const pulse50 = Color(0xFFF8FFE9);
  static const pulse200 = Color(0xFFDBFC9A);
  static const pulse500 = Color(0xFFBDE85F); // base
  static const pulse800 = Color(0xFF5E7C2B);

  // Acento temporal: Bloom (futuro)
  static const bloom50 = Color(0xFFFBEFF5);
  static const bloom200 = Color(0xFFF4B3CF);
  static const bloom500 = Color(0xFFDD4484); // base
  static const bloom800 = Color(0xFF7D1A4C);

  // Retroalimentación al usuario
  static const error = Color(0xFFA63330);
  static const errorContainer = Color(0xFFF2CDCC);
  static const onErrorContainer = Color(0xFF5C1B1A);

  static const success = Color(0xFF5FA549);
  static const successContainer = Color(0xFFD5EDCD);
  static const onSuccessContainer = Color(0xFF2D5220);

  static const info = Color(0xFF6BB5F8);
  static const infoContainer = Color(0xFFC9E3FB);
  static const onInfoContainer = Color(0xFF224F8A);

  static const warning = Color(0xFFEBAC57);
  static const warningContainer = Color(0xFFF2D29B);
  static const onWarningContainer = Color(0xFF6B4B1A);

  // Estados de íconos
  static const iconEnabled = primary500;
  static const iconMuted = neutral200;
  static const iconDisabled = neutral400;

  // Compatibilidad con la pantalla Discover
  static const discover500 = echo500;
  static const discover800 = echo800;
}

// Elevaciones (elevation 50 a 300)
class AppElevation {
  static const double elevation0 = 0;
  static const double elevation1 = 1; // elevation50
  static const double elevation2 = 2; // elevation100
  static const double elevation4 = 4; // elevation200
  static const double elevation8 = 8; // elevation300
}

// Aplica la fuente Lexend a un estilo
TextStyle _lexend(TextStyle estilo) => GoogleFonts.lexend(textStyle: estilo);

final ThemeData audioMack = ThemeData(
  useMaterial3: true,

  scaffoldBackgroundColor: AppColors.neutral800,

  textTheme: TextTheme(
    headlineLarge: _lexend(AppTypography.headline1),
    headlineMedium: _lexend(AppTypography.headline2),
    headlineSmall: _lexend(AppTypography.headline4),
    titleLarge: _lexend(AppTypography.headline3),
    titleMedium: _lexend(AppTypography.subtitle1),
    titleSmall: _lexend(AppTypography.subtitle2),
    bodyLarge: _lexend(AppTypography.body1),
    bodyMedium: _lexend(AppTypography.body2),
    bodySmall: _lexend(AppTypography.caption),
    labelLarge: _lexend(AppTypography.button),
    labelMedium: _lexend(AppTypography.label2),
    labelSmall: _lexend(AppTypography.overline),
  ),

  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary500,
    onPrimary: AppColors.neutral0,
    primaryContainer: AppColors.primary200,
    onPrimaryContainer: AppColors.primary800,
    secondary: AppColors.primary900,
    onSecondary: AppColors.neutral0,
    secondaryContainer: AppColors.neutral500,
    onSecondaryContainer: AppColors.neutral0,
    error: AppColors.error,
    onError: AppColors.neutral0,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.neutral800,
    onSurface: AppColors.neutral50,
    onSurfaceVariant: AppColors.neutral200,
    outline: AppColors.neutral400,
    outlineVariant: AppColors.neutral500,
    surfaceContainerLowest: AppColors.neutral900,
    surfaceContainerLow: AppColors.neutral700,
    surfaceContainer: AppColors.neutral600,
    surfaceContainerHigh: AppColors.neutral500,
    surfaceContainerHighest: AppColors.neutral500,
  ),

  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.neutral800,
    surfaceTintColor: Colors.transparent,
    elevation: AppElevation.elevation0,
    centerTitle: false,
    titleTextStyle: _lexend(AppTypography.headline2),
  ),

  tabBarTheme: TabBarThemeData(
    labelColor: AppColors.neutral0,
    unselectedLabelColor: AppColors.neutral300,
    indicatorColor: AppColors.primary500,
    dividerColor: Colors.transparent,
    labelStyle: _lexend(AppTypography.subtitle1),
    unselectedLabelStyle: _lexend(AppTypography.subtitle1),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary500,
    foregroundColor: AppColors.neutral0,
    shape: CircleBorder(),
  ),

  navigationBarTheme: NavigationBarThemeData(
    height: AppSizes.navBarHeight,
    backgroundColor: AppColors.neutral900,
    surfaceTintColor: Colors.transparent,
    indicatorColor: Colors.transparent,
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.iconEnabled);
        }
        return const IconThemeData(color: AppColors.iconMuted);
      },
    ),
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return _lexend(
            AppTypography.label2.copyWith(color: AppColors.iconEnabled),
          );
        }
        return _lexend(
          AppTypography.label2.copyWith(color: AppColors.iconMuted),
        );
      },
    ),
  ),

  cardTheme: CardThemeData(
    color: AppColors.neutral600,
    elevation: AppElevation.elevation2,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.radius16),
    ),
  ),
);