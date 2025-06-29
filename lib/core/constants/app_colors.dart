import 'package:flutter/material.dart';

class AppColors {
  // Colores principales (compartidos entre temas)
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);

  // Colores secundarios (compartidos entre temas)
  static const Color secondary = Color(0xFF81C784);
  static const Color secondaryLight = Color(0xFFA5D6A7);
  static const Color secondaryDark = Color(0xFF66BB6A);

  // Colores de estado (compartidos entre temas)
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Colores de cámara (compartidos entre temas)
  static const Color cameraOverlay = Color(0x80000000);
  static const Color cameraBorder = Color(0xFF4CAF50);
  static const Color cameraIndicator = Color(0xFF4CAF50);

  // Colores de confianza (compartidos entre temas)
  static const Color highConfidence = Color(0xFF4CAF50);
  static const Color mediumConfidence = Color(0xFFFF9800);
  static const Color lowConfidence = Color(0xFFF44336);

  // Colores de componentes (compartidos entre temas)
  static const Color contentTextLight = Colors.white;
  static const Color surfaceTint = Colors.transparent;

  // ===== COLORES DEL TEMA CLARO =====
  // Colores de fondo del tema claro
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF5F5F5);

  // Colores de texto del tema claro
  static const Color lightTextPrimary = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightTextLight = Color(0xFFBDBDBD);

  // Colores de grises del tema claro
  static const Color lightGrey50 = Color(0xFFFAFAFA);
  static const Color lightGrey300 = Color(0xFFE0E0E0);
  static const Color lightGrey400 = Color(0xFFBDBDBD);
  static const Color lightGrey600 = Color(0xFF757575);
  static const Color lightGrey700 = Color(0xFF616161);
  static const Color lightGrey = Color(0xFF9E9E9E);

  // Colores de efectos del tema claro
  static const Color lightShadow = Color(
    0x1A000000,
  ); // Colors.black.withOpacity(0.1)
  static const Color lightScrim = Color(0x88000000); // Colors.black54

  // ===== COLORES DEL TEMA OSCURO =====
  // Colores de fondo del tema oscuro
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkSurfaceContainer = Color(0xFF2D2D2D);

  // Colores de texto del tema oscuro
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFE0E0E0);
  static const Color darkTextLight = Color(0xFFBDBDBD);

  // Colores de grises del tema oscuro
  static const Color darkGrey50 = Color(0xFF2D2D2D);
  static const Color darkGrey300 = Color(0xFFE0E0E0);
  static const Color darkGrey400 = Color(0xFFBDBDBD);
  static const Color darkGrey600 = Color(0xFF757575);
  static const Color darkGrey700 = Color(0xFF616161);
  static const Color darkGrey = Color(0xFF9E9E9E);

  // Colores de efectos del tema oscuro
  static const Color darkShadow = Color(
    0x4D000000,
  ); // Colors.black.withOpacity(0.3)
  static const Color darkScrim = Color(0x88000000); // Colors.black54
}

class AppGradients {
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [AppColors.success, Color(0xFF66BB6A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [AppColors.error, Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
