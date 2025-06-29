import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Pages
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/camera_page.dart';

/// Configuración de rutas de la aplicación
/// Sigue las reglas de desarrollo establecidas
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash Page
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      
      // Home Page
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      
      // Camera Page
      GoRoute(
        path: '/camara',
        name: 'camera',
        builder: (context, state) => const CameraPage(),
      ),
    ],
    errorBuilder: (context, state) => _buildErrorPage(context, state),
  );

  /// Página de error personalizada
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'La ruta "${state.uri.path}" no existe',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Ir al Inicio'),
            ),
          ],
        ),
      ),
    );
  }

  /// Métodos de navegación
  static void goToHome(BuildContext context) {
    context.go('/home');
  }

  static void goToCamera(BuildContext context) {
    context.go('/camara');
  }

  static void goToSplash(BuildContext context) {
    context.go('/');
  }
}
