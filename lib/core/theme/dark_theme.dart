import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_ui_config.dart';
import 'theme_factory.dart';

/// Tema oscuro de la aplicación
class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ThemeFactory.createColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkBackground,
        onSurface: AppColors.darkTextPrimary,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // AppBar Theme
      appBarTheme: ThemeFactory.createAppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ThemeFactory.createElevatedButtonTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkTextPrimary,
      ),

      // Text Button Theme
      textButtonTheme: ThemeFactory.createTextButtonTheme(
        foregroundColor: AppColors.primary,
      ),

      // Outlined Button Theme
      outlinedButtonTheme: ThemeFactory.createOutlinedButtonTheme(
        foregroundColor: AppColors.primary,
        borderColor: AppColors.primary,
      ),

      // Card Theme
      cardTheme: ThemeFactory.createCardTheme(
        backgroundColor: AppColors.darkCardBackground,
        shadowColor: AppColors.darkShadow,
      ),

      // Input Decoration Theme
      inputDecorationTheme: ThemeFactory.createInputDecorationTheme(
        borderColor: AppColors.darkGrey600,
        focusedBorderColor: AppColors.primary,
        errorBorderColor: AppColors.error,
        fillColor: AppColors.darkSurfaceContainer,
        hintColor: AppColors.darkGrey400,
      ),

      // Text Theme
      textTheme: ThemeFactory.createTextTheme(
        primaryTextColor: AppColors.darkTextPrimary,
        secondaryTextColor: AppColors.darkTextSecondary,
      ),

      // Icon Theme
      iconTheme: ThemeFactory.createIconTheme(color: AppColors.darkTextPrimary),

      // Primary Icon Theme
      primaryIconTheme: ThemeFactory.createIconTheme(
        color: AppColors.darkTextPrimary,
      ),

      // Divider Theme
      dividerTheme: ThemeFactory.createDividerTheme(
        color: AppColors.darkGrey700,
      ),

      // Chip Theme
      chipTheme: ThemeFactory.createChipTheme(
        backgroundColor: AppColors.darkSurfaceContainer,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.darkGrey700,
        labelColor: AppColors.darkTextPrimary,
        secondaryLabelColor: AppColors.darkTextPrimary,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: ThemeFactory.createFloatingActionButtonTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.darkTextPrimary,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: ThemeFactory.createBottomNavigationBarTheme(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.darkGrey,
      ),

      // Dialog Theme
      dialogTheme: ThemeFactory.createDialogTheme(
        backgroundColor: AppColors.darkSurface,
        titleColor: AppColors.darkTextPrimary,
        contentColor: AppColors.darkTextPrimary,
      ),

      // SnackBar Theme
      snackBarTheme: ThemeFactory.createSnackBarTheme(
        backgroundColor: AppColors.primary,
      ),

      // Switch Theme
      switchTheme: ThemeFactory.createSwitchTheme(
        selectedColor: AppColors.primary,
        unselectedThumbColor: AppColors.darkGrey400,
        unselectedTrackColor: AppColors.darkGrey600,
      ),

      // Slider Theme
      sliderTheme: ThemeFactory.createSliderTheme(
        activeColor: AppColors.primary,
        inactiveColor: AppColors.darkGrey600,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ThemeFactory.createProgressIndicatorTheme(
        color: AppColors.primary,
        trackColor: AppColors.darkGrey600,
      ),

      // List Tile Theme
      listTileTheme: ThemeFactory.createListTileTheme(
        titleColor: AppColors.darkTextPrimary,
        subtitleColor: AppColors.darkGrey400,
        leadingColor: AppColors.primary,
        textColor: AppColors.darkTextPrimary,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
      ),

      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurface,
        elevation: AppUIConfig.dialogElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
        ),
        textStyle: const TextStyle(color: AppColors.darkTextPrimary),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        scrimColor: AppColors.darkScrim,
        elevation: AppUIConfig.dialogElevation * 2,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.darkGrey400,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.darkGrey700,
      ),

      // Expansion Tile Theme
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        textColor: AppColors.darkTextPrimary,
        iconColor: AppColors.primary,
        collapsedTextColor: AppColors.darkTextPrimary,
        collapsedIconColor: AppColors.primary,
      ),

      // Data Table Theme
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
        dividerThickness: AppUIConfig.dividerThickness,
        columnSpacing: AppUIConfig.dataTableColumnSpacing,
        horizontalMargin: AppUIConfig.dataTableHorizontalMargin,
        headingRowColor: WidgetStateProperty.all(
          AppColors.darkSurfaceContainer,
        ),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
