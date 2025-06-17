import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Presentation
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/historial_page.dart';
import '../../presentation/pages/settings_page.dart';
import '../../presentation/pages/about_page.dart';

/// Clase para manejo de rutas siguiendo Clean Architecture
class AppRouter {
  static const String home = '/';
  static const String historial = '/historial';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String analysis = '/analysis';

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
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      
      // Ruta de historial
      GoRoute(
        path: historial,
        name: 'historial',
        builder: (context, state) => const HistorialPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HistorialPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      
      // Ruta de configuración
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      
      // Ruta de información
      GoRoute(
        path: about,
        name: 'about',
        builder: (context, state) => const AboutPage(),
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AboutPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(scale: animation, child: child);
          },
        ),
      ),
      
      // Ruta de análisis (con parámetros)
      GoRoute(
        path: '$analysis/:id',
        name: 'analysis',
        builder: (context, state) {
          final analysisId = state.pathParameters['id'];
          return AnalysisDetailPage(analysisId: analysisId ?? '');
        },
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: AnalysisDetailPage(
            analysisId: state.pathParameters['id'] ?? '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
    
    // Manejo de errores
    errorBuilder: (context, state) => _buildErrorPage(context, state),
    
    // Redirecciones
    redirect: (context, state) {
      // Aquí puedes agregar lógica de redirección
      // Por ejemplo, verificar autenticación
      return null;
    },
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
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 0, height: 8),
            Text(
              'La ruta "${state.uri.path}" no existe',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
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

  /// Métodos de navegación estáticos para facilitar el uso
  static void goToHome(BuildContext context) => context.go(home);
  static void goToHistorial(BuildContext context) => context.go(historial);
  static void goToSettings(BuildContext context) => context.go(settings);
  static void goToAbout(BuildContext context) => context.go(about);
  static void goToAnalysis(BuildContext context, String id) => context.go('$analysis/$id');
  
  /// Navegación con push (mantiene la pila de navegación)
  static void pushToHistorial(BuildContext context) => context.push(historial);
  static void pushToSettings(BuildContext context) => context.push(settings);
  static void pushToAbout(BuildContext context) => context.push(about);
  static void pushToAnalysis(BuildContext context, String id) => context.push('$analysis/$id');
  
  /// Navegación con reemplazo
  static void replaceWithHome(BuildContext context) => context.replace(home);
  static void replaceWithHistorial(BuildContext context) => context.replace(historial);
}

/// Página de análisis detallado (placeholder)
/// Esta página no existe en presentation/pages, por eso se mantiene aquí
class AnalysisDetailPage extends StatelessWidget {
  final String analysisId;

  const AnalysisDetailPage({super.key, required this.analysisId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Análisis #$analysisId'),
      ),
      body: Center(
        child: Text('Detalles del análisis $analysisId'),
      ),
    );
  }
} 