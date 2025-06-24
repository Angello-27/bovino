import 'package:flutter/material.dart';
import 'theme_manager.dart';

/// Clase principal de temas de la aplicación
/// Proporciona acceso a los temas claro y oscuro siguiendo Clean Architecture
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

  /// Verifica si un tema es oscuro
  static bool isDarkTheme(ThemeData theme) {
    return ThemeManager.isDarkTheme(theme);
  }

  /// Obtiene el nombre del tema
  static String getThemeName(ThemeData theme) {
    return ThemeManager.getThemeName(theme);
  }

  /// Lista de temas disponibles
  static List<Map<String, dynamic>> get availableThemes =>
      ThemeManager.availableThemes;
}
