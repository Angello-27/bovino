import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Presentation
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/camera_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/not_found_page.dart';

/// Clase para manejo de rutas siguiendo Clean Architecture
/// Proporciona navegación declarativa y manejo de rutas centralizado
class AppRouter {
  // Rutas principales
  static const String home = '/';
  static const String camera = '/camara';
  static const String settings = '/configuracion';

  /// Configuración de rutas usando GoRouter
  static GoRouter get router => GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      // Ruta principal
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
        pageBuilder:
            (context, state) => _buildFadeTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
            ),
      ),

      // Ruta de cámara
      GoRoute(
        path: camera,
        name: 'camera',
        builder: (context, state) => const CameraPage(),
        pageBuilder:
            (context, state) => _buildSlideTransitionPage(
              key: state.pageKey,
              child: const CameraPage(),
            ),
      ),

      // Ruta de configuración
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        pageBuilder:
            (context, state) => _buildSlideTransitionPage(
              key: state.pageKey,
              child: const SettingsPage(),
            ),
      ),
    ],

    // Manejo de errores para rutas no encontradas
    errorBuilder: (context, state) => NotFoundPage(invalidPath: state.uri.path),

    // Redirecciones
    redirect: (context, state) {
      // Aquí se pueden agregar lógicas de redirección
      // Por ejemplo, verificar autenticación, permisos, etc.
      return null;
    },
  );

  /// Métodos de navegación estáticos para facilitar el uso
  static void goToHome(BuildContext context) {
    context.go(home);
  }

  static void goToCamera(BuildContext context) {
    context.go(camera);
  }

  static void goToSettings(BuildContext context) {
    context.go(settings);
  }

  /// Método privado para transición de fade
  static CustomTransitionPage _buildFadeTransitionPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  /// Método privado para transición de slide
  static CustomTransitionPage _buildSlideTransitionPage({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }
}
