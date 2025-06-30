import 'package:logger/logger.dart';

/// Manejador centralizado de errores
/// Previene que errores no críticos cierren la aplicación
class ErrorHandler {
  static final Logger _logger = Logger();

  /// Maneja errores críticos que pueden cerrar la app
  static void handleCriticalError(dynamic error, StackTrace? stackTrace) {
    _logger.e('🚨 Error crítico detectado: $error');
    if (stackTrace != null) {
      _logger.e('Stack trace: $stackTrace');
    }
    
    // Aquí se pueden agregar acciones como:
    // - Enviar reporte de error
    // - Mostrar pantalla de error
    // - Reiniciar servicios críticos
  }

  /// Maneja errores no críticos que no deben cerrar la app
  static void handleNonCriticalError(dynamic error, StackTrace? stackTrace) {
    _logger.w('⚠️ Error no crítico: $error');
    if (stackTrace != null) {
      _logger.d('Stack trace: $stackTrace');
    }
    
    // Continuar con la ejecución normal
  }

  /// Maneja errores de red/conectividad
  static void handleNetworkError(dynamic error) {
    _logger.w('🌐 Error de red: $error');
    
    // No es crítico, la app puede funcionar en modo offline
  }

  /// Maneja errores de inicialización
  static void handleInitializationError(dynamic error) {
    _logger.e('🔧 Error de inicialización: $error');
    
    // Intentar continuar con inicialización parcial
  }

  /// Verifica si un error es crítico
  static bool isCriticalError(dynamic error) {
    // Lista de errores que se consideran críticos
    final criticalErrors = [
      'OutOfMemoryError',
      'StackOverflowError',
      'AssertionError',
      'StateError',
    ];
    
    final errorString = error.toString().toLowerCase();
    return criticalErrors.any((critical) => 
      errorString.contains(critical.toLowerCase())
    );
  }

  /// Ejecuta una función con manejo de errores
  static Future<T?> safeExecute<T>(
    Future<T> Function() function, {
    T? defaultValue,
    bool rethrowCritical = true,
  }) async {
    try {
      return await function();
    } catch (error, stackTrace) {
      if (isCriticalError(error)) {
        handleCriticalError(error, stackTrace);
        if (rethrowCritical) rethrow;
      } else {
        handleNonCriticalError(error, stackTrace);
      }
      return defaultValue;
    }
  }

  /// Ejecuta una función síncrona con manejo de errores
  static T? safeExecuteSync<T>(
    T Function() function, {
    T? defaultValue,
    bool rethrowCritical = true,
  }) {
    try {
      return function();
    } catch (error, stackTrace) {
      if (isCriticalError(error)) {
        handleCriticalError(error, stackTrace);
        if (rethrowCritical) rethrow;
      } else {
        handleNonCriticalError(error, stackTrace);
      }
      return defaultValue;
    }
  }
} 