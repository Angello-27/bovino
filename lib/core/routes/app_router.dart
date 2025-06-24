import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/home_page.dart';

/// Clase para manejo de rutas siguiendo Clean Architecture
class AppRouter {
  static const String home = '/';

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
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomePage(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
      ),
    ],

    // Manejo de errores
    errorBuilder: (context, state) => _buildErrorPage(context, state),
  );

  /// Página de error personalizada
  static Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 0, height: 8),
            Text(
              'La ruta "${state.uri.path}" no existe',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(home),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
