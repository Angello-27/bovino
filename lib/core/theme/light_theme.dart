import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Tema claro de la aplicación
class LightTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(AppConstants.uiConfig['primaryColor']),
        brightness: Brightness.light,
        primary: const Color(AppConstants.uiConfig['primaryColor']),
        secondary: const Color(AppConstants.uiConfig['secondaryColor']),
        background: const Color(AppConstants.uiConfig['backgroundColor']),
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: const Color(AppConstants.uiConfig['textColor']),
        onSurface: const Color(AppConstants.uiConfig['textColor']),
        onError: Colors.white,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: const Color(AppConstants.uiConfig['backgroundColor']),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
        margin: const EdgeInsets.all(AppConstants.uiConfig['margin']),
        color: Colors.white,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          borderSide: BorderSide(color: Colors.grey[300]!),
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
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.all(AppConstants.uiConfig['padding']),
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(AppConstants.uiConfig['primaryColor']),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
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
        backgroundColor: Colors.white,
        elevation: 8,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(AppConstants.uiConfig['primaryColor']),
        disabledColor: Colors.grey[300],
        labelStyle: const TextStyle(color: Color(AppConstants.uiConfig['textColor'])),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
        ),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(AppConstants.uiConfig['textColor']),
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
          return Colors.grey;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(AppConstants.uiConfig['primaryColor']).withOpacity(0.5);
          }
          return Colors.grey[300];
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(AppConstants.uiConfig['primaryColor']),
        inactiveTrackColor: Colors.grey[300],
        thumbColor: const Color(AppConstants.uiConfig['primaryColor']),
        overlayColor: const Color(AppConstants.uiConfig['primaryColor']).withOpacity(0.2),
        valueIndicatorColor: const Color(AppConstants.uiConfig['primaryColor']),
        valueIndicatorTextStyle: const TextStyle(color: Colors.white),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(AppConstants.uiConfig['primaryColor']),
        linearTrackColor: Colors.grey,
        circularTrackColor: Colors.grey,
      ),
      
      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        leadingAndTrailingTextStyle: const TextStyle(
          fontSize: 14,
          color: Color(AppConstants.uiConfig['textColor']),
        ),
        iconColor: const Color(AppConstants.uiConfig['primaryColor']),
        textColor: const Color(AppConstants.uiConfig['textColor']),
      ),
    );
  }
} 