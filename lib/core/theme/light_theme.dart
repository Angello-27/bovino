import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'theme_factory.dart';

/// Tema claro de la aplicación
class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ThemeFactory.createColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightBackground,
        onSurface: AppColors.lightTextPrimary,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.lightBackground,

      // AppBar Theme
      appBarTheme: ThemeFactory.createAppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ThemeFactory.createElevatedButtonTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
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
        backgroundColor: AppColors.lightCardBackground,
        shadowColor: AppColors.lightShadow,
      ),

      // Input Decoration Theme
      inputDecorationTheme: ThemeFactory.createInputDecorationTheme(
        borderColor: AppColors.lightGrey300,
        focusedBorderColor: AppColors.primary,
        errorBorderColor: AppColors.error,
        fillColor: AppColors.lightGrey50,
        hintColor: AppColors.lightTextSecondary,
      ),

      // Text Theme
      textTheme: ThemeFactory.createTextTheme(
        primaryTextColor: AppColors.lightTextPrimary,
        secondaryTextColor: AppColors.lightTextSecondary,
      ),

      // Icon Theme
      iconTheme: ThemeFactory.createIconTheme(
        color: AppColors.lightTextPrimary,
      ),

      // Primary Icon Theme
      primaryIconTheme: ThemeFactory.createIconTheme(
        color: AppColors.contentTextLight,
      ),

      // Divider Theme
      dividerTheme: ThemeFactory.createDividerTheme(
        color: AppColors.lightGrey300,
      ),

      // Chip Theme
      chipTheme: ThemeFactory.createChipTheme(
        backgroundColor: AppColors.lightSurface,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.lightGrey300,
        labelColor: AppColors.lightTextPrimary,
        secondaryLabelColor: AppColors.contentTextLight,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: ThemeFactory.createFloatingActionButtonTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: ThemeFactory.createBottomNavigationBarTheme(
        backgroundColor: AppColors.contentTextLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.lightGrey,
      ),

      // Dialog Theme
      dialogTheme: ThemeFactory.createDialogTheme(
        backgroundColor: AppColors.contentTextLight,
        titleColor: AppColors.lightTextPrimary,
        contentColor: AppColors.lightTextPrimary,
      ),

      // SnackBar Theme
      snackBarTheme: ThemeFactory.createSnackBarTheme(
        backgroundColor: AppColors.primary,
      ),

      // Switch Theme
      switchTheme: ThemeFactory.createSwitchTheme(
        selectedColor: AppColors.primary,
        unselectedThumbColor: AppColors.lightGrey,
        unselectedTrackColor: AppColors.lightGrey300,
      ),

      // Slider Theme
      sliderTheme: ThemeFactory.createSliderTheme(
        activeColor: AppColors.primary,
        inactiveColor: AppColors.lightGrey300,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ThemeFactory.createProgressIndicatorTheme(
        color: AppColors.primary,
        trackColor: AppColors.lightGrey,
      ),

      // List Tile Theme
      listTileTheme: ThemeFactory.createListTileTheme(
        titleColor: AppColors.lightTextPrimary,
        subtitleColor: AppColors.lightGrey600,
        leadingColor: AppColors.primary,
        textColor: AppColors.lightTextPrimary,
      ),

      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
        ),
        textStyle: TextStyle(color: AppColors.lightTextPrimary),
      ),

      // Drawer Theme
      drawerTheme: DrawerThemeData(
        backgroundColor: AppColors.lightSurface,
        scrimColor: AppColors.lightScrim,
        elevation: 16,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        modalBackgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.lightGrey400,
        indicatorColor: AppColors.primary,
        dividerColor: AppColors.lightGrey300,
      ),

      // Expansion Tile Theme
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        textColor: AppColors.lightTextPrimary,
        iconColor: AppColors.primary,
        collapsedTextColor: AppColors.lightTextPrimary,
        collapsedIconColor: AppColors.primary,
      ),

      // Data Table Theme
      dataTableTheme: DataTableThemeData(
        headingTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: TextStyle(color: AppColors.lightTextPrimary),
        dividerThickness: 1,
        columnSpacing: 16,
        horizontalMargin: 16,
        headingRowColor: WidgetStateProperty.all(AppColors.lightGrey50),
        dataRowColor: WidgetStateProperty.all(Colors.transparent),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 52,
      ),
    );
  }
}
