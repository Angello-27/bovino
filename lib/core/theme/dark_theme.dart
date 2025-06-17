import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Tema oscuro de la aplicación
class DarkTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.uiConfig['primaryColor']),
        brightness: Brightness.dark,
        primary: const Color(AppConstants.uiConfig['primaryColor']),
        secondary: const Color(AppConstants.uiConfig['secondaryColor']),
        background: const Color(0xFF121212), // Dark background
        surface: const Color(0xFF1E1E1E), // Dark surface
        error: Colors.red[400]!,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        surfaceVariant: const Color(0xFF2D2D2D),
        onSurfaceVariant: Colors.grey[300]!,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          ),
          elevation: 2,
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppConstants.uiConfig['primaryColor']),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(AppConstants.uiConfig['primaryColor']),
          side: const BorderSide(
            color: Color(AppConstants.uiConfig['primaryColor']),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
        margin: const EdgeInsets.all(AppConstants.uiConfig['margin']),
        color: const Color(0xFF1E1E1E),
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          borderSide: const BorderSide(
            color: Color(AppConstants.uiConfig['primaryColor']),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          borderSide: BorderSide(color: Colors.red[400]!, width: 1),
        ),
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        contentPadding: const EdgeInsets.all(AppConstants.uiConfig['padding']),
        hintStyle: TextStyle(color: Colors.grey[400]),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(AppConstants.uiConfig['primaryColor']),
        foregroundColor: Colors.white,
        elevation: 6,
        shape: CircleBorder(),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: Color(AppConstants.uiConfig['primaryColor']),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 8,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2D2D2D),
        selectedColor: const Color(AppConstants.uiConfig['primaryColor']),
        disabledColor: Colors.grey[700],
        labelStyle: const TextStyle(color: Colors.white),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[700],
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: Colors.white,
        size: 24,
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppConstants.uiConfig['primaryColor']);
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppConstants.uiConfig['primaryColor']).withOpacity(0.5);
          }
          return Colors.grey[600];
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(AppConstants.uiConfig['primaryColor']),
        inactiveTrackColor: Colors.grey[600],
        thumbColor: const Color(AppConstants.uiConfig['primaryColor']),
        overlayColor: const Color(AppConstants.uiConfig['primaryColor']).withOpacity(0.2),
        valueIndicatorColor: const Color(AppConstants.uiConfig['primaryColor']),
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: const Color(AppConstants.uiConfig['primaryColor']),
        linearTrackColor: Colors.grey[600],
        circularTrackColor: Colors.grey[600],
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        iconColor: const Color(AppConstants.uiConfig['primaryColor']),
        textColor: Colors.white,
        tileColor: Colors.transparent,
        selectedTileColor: const Color(AppConstants.uiConfig['primaryColor']).withOpacity(0.1),
      ),
      
      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
        textStyle: const TextStyle(color: Colors.white),
      ),
      
      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        scrimColor: Colors.black54,
        elevation: 16,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        modalBackgroundColor: Color(0xFF1E1E1E),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      
      // Tab Bar Theme
      tabBarTheme: TabBarTheme(
        labelColor: const Color(AppConstants.uiConfig['primaryColor']),
        unselectedLabelColor: Colors.grey[400],
        indicatorColor: const Color(AppConstants.uiConfig['primaryColor']),
        dividerColor: Colors.grey[700],
      ),
      
      // Expansion Tile Theme
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        textColor: Colors.white,
        iconColor: const Color(AppConstants.uiConfig['primaryColor']),
        collapsedTextColor: Colors.white,
        collapsedIconColor: const Color(AppConstants.uiConfig['primaryColor']),
      ),
      
      // Data Table Theme
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        dataTextStyle: const TextStyle(color: Colors.white),
        dividerThickness: 1,
        columnSpacing: 16,
        horizontalMargin: 16,
        headingRowColor: MaterialStateProperty.all(const Color(0xFF2D2D2D)),
        dataRowColor: MaterialStateProperty.all(Colors.transparent),
        dataRowMinHeight: 52,
        dataRowMaxHeight: 52,
      ),
    );
  }
} 