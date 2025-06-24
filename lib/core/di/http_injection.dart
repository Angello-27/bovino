import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';

/// Módulo para inyección de dependencias HTTP
/// Sigue Clean Architecture y separación de responsabilidades
class HttpInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Configura el cliente HTTP (Dio)
  static Future<void> setup() async {
    final dio = Dio();
    dio.options.connectTimeout = AppConstants.timeoutSeconds;
    dio.options.receiveTimeout = AppConstants.timeoutSeconds;
    dio.options.headers['Content-Type'] = 'application/json';

    // Configurar interceptores para logging (solo en debug)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.i('🌐 HTTP Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('✅ HTTP Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('❌ HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );

    _getIt.registerSingleton<Dio>(dio);
    _logger.i('🔧 HTTP Client configured successfully');
  }

  /// Obtiene la instancia de Dio
  static Dio get dio => _getIt<Dio>();

  /// Limpia las dependencias HTTP
  static Future<void> dispose() async {
    try {
      final dio = _getIt<Dio>();
      dio.close();
      _logger.i('🔧 HTTP Client disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing HTTP Client: $e');
    }
  }
}
