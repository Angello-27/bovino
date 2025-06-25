import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_ui_config.dart';

/// Factory para crear temas compartidos y eliminar redundancia
class ThemeFactory {
  /// Crea el esquema de colores base
  static ColorScheme createColorScheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color surface,
    required Color onSurface,
  }) {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: brightness,
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurface,
      onError: Colors.white,
      surfaceContainerHighest:
          brightness == Brightness.dark
              ? AppColors.darkGrey50
              : AppColors.lightGrey50,
      onSurfaceVariant:
          brightness == Brightness.dark
              ? AppColors.darkGrey300
              : AppColors.lightGrey700,
    );
  }

  /// Crea el tema del AppBar
  static AppBarTheme createAppBarTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: AppUIConfig.appBarElevation,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppUIConfig.fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: foregroundColor,
      ),
      iconTheme: IconThemeData(color: foregroundColor),
      surfaceTintColor: AppColors.surfaceTint,
    );
  }

  /// Crea el tema de botones elevados
  static ElevatedButtonThemeData createElevatedButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: AppUIConfig.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
        ),
        elevation: AppUIConfig.buttonElevation,
      ),
    );
  }

  /// Crea el tema de botones de texto
  static TextButtonThemeData createTextButtonTheme({
    required Color foregroundColor,
  }) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: AppUIConfig.textButtonPadding,
      ),
    );
  }

  /// Crea el tema de botones con contorno
  static OutlinedButtonThemeData createOutlinedButtonTheme({
    required Color foregroundColor,
    required Color borderColor,
  }) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: AppUIConfig.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
        ),
      ),
    );
  }

  /// Crea el tema de tarjetas
  static CardThemeData createCardTheme({
    required Color backgroundColor,
    required Color shadowColor,
  }) {
    return CardThemeData(
      elevation: AppUIConfig.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
      margin: const EdgeInsets.all(AppUIConfig.margin),
      color: backgroundColor,
      shadowColor: shadowColor,
      surfaceTintColor: AppColors.surfaceTint,
    );
  }

  /// Crea el tema de decoración de inputs
  static InputDecorationTheme createInputDecorationTheme({
    required Color borderColor,
    required Color focusedBorderColor,
    required Color errorBorderColor,
    required Color fillColor,
    required Color hintColor,
  }) {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: AppUIConfig.inputPadding,
      hintStyle: TextStyle(color: hintColor),
    );
  }

  /// Crea el tema de texto
  static TextTheme createTextTheme({
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: AppUIConfig.fontSizeHeadline,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      displayMedium: TextStyle(
        fontSize: AppUIConfig.fontSizeTitle,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      displaySmall: TextStyle(
        fontSize: AppUIConfig.fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      headlineLarge: TextStyle(
        fontSize: AppUIConfig.fontSizeHeadline,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      headlineMedium: TextStyle(
        fontSize: AppUIConfig.fontSizeXXLarge,
        fontWeight: FontWeight.bold,
        color: primaryTextColor,
      ),
      headlineSmall: TextStyle(
        fontSize: AppUIConfig.fontSizeXLarge,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleLarge: TextStyle(
        fontSize: AppUIConfig.fontSizeXLarge,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleMedium: TextStyle(
        fontSize: AppUIConfig.fontSizeLarge,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontSize: AppUIConfig.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      ),
      bodyLarge: TextStyle(fontSize: AppUIConfig.fontSizeLarge, color: primaryTextColor),
      bodyMedium: TextStyle(fontSize: AppUIConfig.fontSizeMedium, color: primaryTextColor),
      bodySmall: TextStyle(fontSize: AppUIConfig.fontSizeSmall, color: secondaryTextColor),
      labelLarge: TextStyle(
        fontSize: AppUIConfig.fontSizeMedium,
        fontWeight: FontWeight.w500,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontSize: AppUIConfig.fontSizeSmall,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontSize: AppUIConfig.fontSizeSmall - 2,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }

  /// Crea el tema de iconos
  static IconThemeData createIconTheme({required Color color}) {
    return IconThemeData(color: color, size: AppUIConfig.iconSize);
  }

  /// Crea el tema de divisores
  static DividerThemeData createDividerTheme({required Color color}) {
    return DividerThemeData(
      color: color,
      thickness: AppUIConfig.dividerThickness,
      space: AppUIConfig.margin,
    );
  }

  /// Crea el tema de chips
  static ChipThemeData createChipTheme({
    required Color backgroundColor,
    required Color selectedColor,
    required Color disabledColor,
    required Color labelColor,
    required Color secondaryLabelColor,
  }) {
    return ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      disabledColor: disabledColor,
      labelStyle: TextStyle(color: labelColor),
      secondaryLabelStyle: TextStyle(color: secondaryLabelColor),
      padding: AppUIConfig.chipPadding,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
    );
  }

  /// Crea el tema de botón flotante
  static FloatingActionButtonThemeData createFloatingActionButtonTheme({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return FloatingActionButtonThemeData(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: AppUIConfig.floatingActionButtonElevation,
    );
  }

  /// Crea el tema de barra de navegación inferior
  static BottomNavigationBarThemeData createBottomNavigationBarTheme({
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return BottomNavigationBarThemeData(
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      type: BottomNavigationBarType.fixed,
      elevation: AppUIConfig.cardElevation * 2,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
  }

  /// Crea el tema de diálogos
  static DialogThemeData createDialogTheme({
    required Color backgroundColor,
    required Color titleColor,
    required Color contentColor,
  }) {
    return DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
      backgroundColor: backgroundColor,
      elevation: AppUIConfig.dialogElevation,
      titleTextStyle: TextStyle(
        fontSize: AppUIConfig.fontSizeXLarge,
        fontWeight: FontWeight.bold,
        color: titleColor,
      ),
      contentTextStyle: TextStyle(fontSize: AppUIConfig.fontSizeMedium, color: contentColor),
      surfaceTintColor: AppColors.surfaceTint,
    );
  }

  /// Crea el tema de SnackBar
  static SnackBarThemeData createSnackBarTheme({
    required Color backgroundColor,
  }) {
    return SnackBarThemeData(
      backgroundColor: backgroundColor,
      contentTextStyle: TextStyle(color: AppColors.contentTextLight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: AppUIConfig.cardElevation * 1.5,
    );
  }

  /// Crea el tema de switch
  static SwitchThemeData createSwitchTheme({
    required Color selectedColor,
    required Color unselectedThumbColor,
    required Color unselectedTrackColor,
  }) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selectedColor;
        }
        return unselectedThumbColor;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return selectedColor.withValues(alpha: 0.5);
        }
        return unselectedTrackColor;
      }),
    );
  }

  /// Crea el tema de slider
  static SliderThemeData createSliderTheme({
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return SliderThemeData(
      activeTrackColor: activeColor,
      inactiveTrackColor: inactiveColor,
      thumbColor: activeColor,
      overlayColor: activeColor.withValues(alpha: 0.2),
      valueIndicatorColor: activeColor,
      valueIndicatorTextStyle: TextStyle(color: AppColors.contentTextLight),
    );
  }

  /// Crea el tema de indicador de progreso
  static ProgressIndicatorThemeData createProgressIndicatorTheme({
    required Color color,
    required Color trackColor,
  }) {
    return ProgressIndicatorThemeData(
      color: color,
      linearTrackColor: trackColor,
      circularTrackColor: trackColor,
    );
  }

  /// Crea el tema de list tile
  static ListTileThemeData createListTileTheme({
    required Color titleColor,
    required Color subtitleColor,
    required Color leadingColor,
    required Color textColor,
    Color? selectedTileColor,
  }) {
    return ListTileThemeData(
      contentPadding: AppUIConfig.listTilePadding,
      titleTextStyle: TextStyle(
        fontSize: AppUIConfig.fontSizeLarge,
        fontWeight: FontWeight.w500,
        color: titleColor,
      ),
      subtitleTextStyle: TextStyle(fontSize: AppUIConfig.fontSizeMedium, color: subtitleColor),
      leadingAndTrailingTextStyle: TextStyle(fontSize: AppUIConfig.fontSizeMedium, color: textColor),
      iconColor: leadingColor,
      textColor: textColor,
      tileColor: Colors.transparent,
      selectedTileColor: selectedTileColor,
    );
  }
}
