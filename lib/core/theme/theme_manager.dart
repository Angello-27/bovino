import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_messages.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Gestor de temas de la aplicación
/// Centraliza la gestión de temas claro y oscuro siguiendo Clean Architecture
class ThemeManager {
  /// Tema claro de la aplicación
  static ThemeData get lightTheme => LightTheme.theme;

  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme => DarkTheme.theme;

  /// Tema por defecto
  static ThemeData get defaultTheme => lightTheme;

  /// Obtiene el tema basado en el modo del sistema
  static ThemeData getThemeByBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  /// Obtiene el tema basado en un valor booleano
  static ThemeData getThemeByBool(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }

  /// Verifica si un tema es oscuro
  static bool isDarkTheme(ThemeData theme) {
    return theme.brightness == Brightness.dark;
  }

  /// Obtiene el nombre del tema
  static String getThemeName(ThemeData theme) {
    return isDarkTheme(theme) ? AppMessages.themeDark : AppMessages.themeLight;
  }

  /// Lista de temas disponibles
  static List<Map<String, dynamic>> get availableThemes => [
    {
      'name': AppMessages.themeLight,
      'theme': lightTheme,
      'icon': Icons.light_mode,
      'description': AppMessages.themeLightDescription,
    },
    {
      'name': AppMessages.themeDark,
      'theme': darkTheme,
      'icon': Icons.dark_mode,
      'description': AppMessages.themeDarkDescription,
    },
  ];

  /// Obtiene colores de estado para un tema
  static Map<String, Color> getStatusColors(ThemeData theme) {
    final isDark = isDarkTheme(theme);

    return {
      'success': isDark ? AppColors.success : AppColors.success,
      'warning': isDark ? AppColors.warning : AppColors.warning,
      'error': isDark ? AppColors.error : AppColors.error,
      'info': isDark ? AppColors.info : AppColors.info,
    };
  }
}
