import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Gestor de temas de la aplicación
/// Centraliza la gestión de temas claro y oscuro
class ThemeManager {
  /// Tema claro de la aplicación
  static ThemeData get lightTheme => LightTheme.theme;
  
  /// Tema oscuro de la aplicación
  static ThemeData get darkTheme => DarkTheme.theme;
  
  /// Obtiene el tema basado en el modo del sistema
  static ThemeData getThemeByBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }
  
  /// Obtiene el tema basado en un valor booleano
  static ThemeData getThemeByBool(bool isDark) {
    return isDark ? darkTheme : lightTheme;
  }
  
  /// Obtiene el tema basado en una cadena
  static ThemeData getThemeByString(String themeName) {
    switch (themeName.toLowerCase()) {
      case 'dark':
      case 'oscuro':
        return darkTheme;
      case 'light':
      case 'claro':
      default:
        return lightTheme;
    }
  }
  
  /// Verifica si un tema es oscuro
  static bool isDarkTheme(ThemeData theme) {
    return theme.brightness == Brightness.dark;
  }
  
  /// Obtiene el nombre del tema
  static String getThemeName(ThemeData theme) {
    return isDarkTheme(theme) ? 'Oscuro' : 'Claro';
  }
  
  /// Lista de temas disponibles
  static List<Map<String, dynamic>> get availableThemes => [
    {
      'name': 'Claro',
      'theme': lightTheme,
      'icon': Icons.light_mode,
      'description': 'Tema claro para uso diurno',
    },
    {
      'name': 'Oscuro',
      'theme': darkTheme,
      'icon': Icons.dark_mode,
      'description': 'Tema oscuro para uso nocturno',
    },
  ];
  
  /// Obtiene información de un tema específico
  static Map<String, dynamic>? getThemeInfo(String themeName) {
    try {
      return availableThemes.firstWhere(
        (theme) => theme['name'].toString().toLowerCase() == themeName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
  
  /// Obtiene el tema por defecto
  static ThemeData get defaultTheme => lightTheme;
  
  /// Obtiene el tema del sistema
  static ThemeData get systemTheme => lightTheme; // Por defecto, se puede cambiar dinámicamente
  
  /// Aplica un tema personalizado con modificaciones
  static ThemeData applyCustomTheme({
    required ThemeData baseTheme,
    Color? primaryColor,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? textColor,
    double? borderRadius,
  }) {
    return baseTheme.copyWith(
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: primaryColor ?? baseTheme.colorScheme.primary,
        background: backgroundColor ?? baseTheme.colorScheme.background,
        surface: surfaceColor ?? baseTheme.colorScheme.surface,
        onBackground: textColor ?? baseTheme.colorScheme.onBackground,
        onSurface: textColor ?? baseTheme.colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: backgroundColor ?? baseTheme.scaffoldBackgroundColor,
      cardTheme: baseTheme.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
          ),
        ),
      ),
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
    final baseTheme = isDark ? darkTheme : lightTheme;
    
    return baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        onBackground: textColor,
        onSurface: textColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: baseTheme.cardTheme.copyWith(
        color: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2,
        ),
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      iconTheme: IconThemeData(color: textColor),
    );
  }
  
  /// Obtiene colores de acento para un tema
  static List<Color> getAccentColors(ThemeData theme) {
    final isDark = isDarkTheme(theme);
    
    if (isDark) {
      return [
        const Color(0xFF64B5F6), // Blue
        const Color(0xFF81C784), // Green
        const Color(0xFFFFB74D), // Orange
        const Color(0xFFE57373), // Red
        const Color(0xFFBA68C8), // Purple
        const Color(0xFF4DB6AC), // Teal
      ];
    } else {
      return [
        const Color(0xFF1976D2), // Blue
        const Color(0xFF388E3C), // Green
        const Color(0xFFF57C00), // Orange
        const Color(0xFFD32F2F), // Red
        const Color(0xFF7B1FA2), // Purple
        const Color(0xFF00796B), // Teal
      ];
    }
  }
  
  /// Obtiene colores de estado para un tema
  static Map<String, Color> getStatusColors(ThemeData theme) {
    final isDark = isDarkTheme(theme);
    
    return {
      'success': isDark ? const Color(0xFF81C784) : const Color(0xFF4CAF50),
      'warning': isDark ? const Color(0xFFFFB74D) : const Color(0xFFFF9800),
      'error': isDark ? const Color(0xFFE57373) : const Color(0xFFF44336),
      'info': isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
    };
  }
  
  /// Obtiene el contraste de un color con el fondo
  static double getContrastRatio(Color color, Color backgroundColor) {
    final luminance1 = color.computeLuminance();
    final luminance2 = backgroundColor.computeLuminance();
    
    final brightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final darkest = luminance1 > luminance2 ? luminance2 : luminance1;
    
    return (brightest + 0.05) / (darkest + 0.05);
  }
  
  /// Verifica si un color tiene suficiente contraste
  static bool hasGoodContrast(Color color, Color backgroundColor) {
    return getContrastRatio(color, backgroundColor) >= 4.5;
  }
  
  /// Obtiene un color de texto apropiado para un fondo
  static Color getAppropriateTextColor(Color backgroundColor) {
    return hasGoodContrast(Colors.white, backgroundColor) 
        ? Colors.white 
        : Colors.black;
  }
} 