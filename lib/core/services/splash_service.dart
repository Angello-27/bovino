import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

/// Servicio para manejar la lógica del splash screen
/// Sigue la arquitectura y reglas de desarrollo establecidas
class SplashService {
  final Logger _logger = Logger();
  final Dio _dio = Dio();

  /// Duración mínima del splash screen
  static const Duration minSplashDuration = Duration(seconds: 2);

  /// Inicializa el splash screen y retorna cuando está listo
  Future<void> initialize() async {
    _logger.i('🚀 Iniciando splash screen...');

    try {
      // Simular carga de recursos
      await _loadResources();

      // Asegurar duración mínima
      await Future.delayed(minSplashDuration);

      _logger.i('✅ Splash screen completado exitosamente');
    } catch (e) {
      _logger.e('❌ Error en splash screen: $e');
      // No rethrow para evitar que la app se cierre
      _logger.w('⚠️ Continuando con splash screen...');
    }
  }

  /// Carga recursos necesarios para la aplicación
  Future<void> _loadResources() async {
    _logger.d('📦 Cargando recursos de la aplicación...');

    try {
      // Aquí se pueden cargar recursos como:
      // - Configuraciones
      // - Datos iniciales
      // - Verificar conexión al servidor
      // - Cargar temas
      // - Inicializar servicios

      await Future.delayed(const Duration(milliseconds: 500));

      _logger.d('✅ Recursos cargados exitosamente');
    } catch (e) {
      _logger.w('⚠️ Advertencia al cargar recursos: $e');
      // Continuar sin fallar
    }
  }

  /// Verifica si el servidor está disponible
  Future<bool> checkServerConnection() async {
    try {
      _logger.i('🔍 Verificando conexión al servidor: ${AppConstants.serverBaseUrl}');

      // Configurar timeout para la verificación
      _dio.options.connectTimeout = AppConstants.connectionTimeout;
      _dio.options.receiveTimeout = AppConstants.connectionTimeout;

      // Intentar conectar al endpoint de health check
      final response = await _dio.get('${AppConstants.serverBaseUrl}${ApiEndpoints.healthCheck}');
      
      if (response.statusCode == 200) {
        _logger.i('✅ Servidor disponible - Status: ${response.statusCode}');
        _logger.d('📡 Respuesta del servidor: ${response.data}');
        return true;
      } else {
        _logger.w('⚠️ Servidor respondió con status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      _logger.e('❌ Error de conexión al servidor: ${e.message}');
      _logger.d('🔍 Tipo de error: ${e.type}');
      _logger.d('🔍 Código de error: ${e.response?.statusCode}');
      
      if (e.type == DioExceptionType.connectionTimeout) {
        _logger.e('⏰ Timeout de conexión al servidor');
      } else if (e.type == DioExceptionType.connectionError) {
        _logger.e('🌐 Error de conexión de red');
      }
      
      return false;
    } catch (e) {
      _logger.e('❌ Error inesperado al verificar servidor: $e');
      return false;
    }
  }
}
