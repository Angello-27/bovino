import 'package:flutter/material.dart';
import 'theme_manager.dart';

/// Clase principal de temas de la aplicación
/// Proporciona acceso a los temas claro y oscuro
class AppTheme {
  /// Tema claro de la aplicación
  static ThemeData get lightTheme => ThemeManager.lightTheme;
  
  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme => ThemeManager.darkTheme;
  
  /// Tema por defecto (claro)
  static ThemeData get defaultTheme => ThemeManager.defaultTheme;
  
  /// Obtiene el tema basado en el modo del sistema
  static ThemeData getThemeByBrightness(Brightness brightness) {
    return ThemeManager.getThemeByBrightness(brightness);
  }
  
  /// Obtiene el tema basado en un valor booleano
  static ThemeData getThemeByBool(bool isDark) {
    return ThemeManager.getThemeByBool(isDark);
  }
  
  /// Obtiene el tema basado en una cadena
  static ThemeData getThemeByString(String themeName) {
    return ThemeManager.getThemeByString(themeName);
  }
  
  /// Verifica si un tema es oscuro
  static bool isDarkTheme(ThemeData theme) {
    return ThemeManager.isDarkTheme(theme);
  }
  
  /// Obtiene el nombre del tema
  static String getThemeName(ThemeData theme) {
    return ThemeManager.getThemeName(theme);
  }
  
  /// Lista de temas disponibles
  static List<Map<String, dynamic>> get availableThemes => ThemeManager.availableThemes;
  
  /// Obtiene información de un tema específico
  static Map<String, dynamic>? getThemeInfo(String themeName) {
    return ThemeManager.getThemeInfo(themeName);
  }
  
  /// Aplica un tema personalizado con modificaciones
  static ThemeData applyCustomTheme({
    required ThemeData baseTheme,
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    double? borderRadius,
  }) {
    return ThemeManager.applyCustomTheme(
      baseTheme: baseTheme,
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      borderRadius: borderRadius,
    );
  }
  
  /// Crea un tema con colores personalizados
  static ThemeData createCustomTheme({
    required Color primaryColor,
    required Color backgroundColor,
    required Color surfaceColor,
    required Color textColor,
    required bool isDark,
    double borderRadius = 8,
  }) {
    return ThemeManager.createCustomTheme(
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      surfaceColor: surfaceColor,
      textColor: textColor,
      isDark: isDark,
      borderRadius: borderRadius,
    );
  }
  
  /// Obtiene colores de acento para un tema
  static List<Color> getAccentColors(ThemeData theme) {
    return ThemeManager.getAccentColors(theme);
  }
  
  /// Obtiene colores de estado para un tema
  static Map<String, Color> getStatusColors(ThemeData theme) {
    return ThemeManager.getStatusColors(theme);
  }
  
  /// Obtiene el contraste de un color con el fondo
  static double getContrastRatio(Color color, Color backgroundColor) {
    return ThemeManager.getContrastRatio(color, backgroundColor);
  }
  
  /// Verifica si un color tiene suficiente contraste
  static bool hasGoodContrast(Color color, Color backgroundColor) {
    return ThemeManager.hasGoodContrast(color, backgroundColor);
  }
  
  /// Obtiene un color de texto apropiado para un fondo
  static Color getAppropriateTextColor(Color backgroundColor) {
    return ThemeManager.getAppropriateTextColor(backgroundColor);
  }
} 