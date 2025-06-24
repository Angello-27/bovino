import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// DI Modules
import 'http_injection.dart';
import 'websocket_injection.dart';
import 'services_injection.dart';
import 'data_injection.dart';
import 'presentation_injection.dart';

/// Coordinador principal para inyección de dependencias
/// Sigue Clean Architecture y separación de responsabilidades
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Inicializa todas las dependencias en orden correcto
  static Future<void> initialize() async {
    try {
      _logger.i('🚀 Starting dependency injection...');

      // 1. Configurar infraestructura (HTTP, WebSocket)
      await HttpInjection.setup();
      await WebSocketInjection.setup();

      // 2. Configurar servicios core
      await ServicesInjection.setup();

      // 3. Configurar capa de datos
      await DataInjection.setup();

      // 4. Configurar capa de presentación
      await PresentationInjection.setup();

      _logger.i('✅ All dependencies initialized successfully');
    } catch (e) {
      _logger.e('❌ Error initializing dependencies: $e');
      rethrow;
    }
  }

  /// Getters delegados a los módulos específicos
  // HTTP
  static get dio => HttpInjection.dio;

  // WebSocket
  static get websocket => WebSocketInjection.websocket;

  // Services
  static get cameraService => ServicesInjection.cameraService;
  static get permissionService => ServicesInjection.permissionService;
  static get splashService => ServicesInjection.splashService;

  // Data
  static get remoteDataSource => DataInjection.remoteDataSource;
  static get repository => DataInjection.repository;

  // Presentation
  static get cameraBloc => PresentationInjection.cameraBloc;
  static get bovinoBloc => PresentationInjection.bovinoBloc;
  static get themeBloc => PresentationInjection.themeBloc;
  static get splashBloc => PresentationInjection.splashBloc;

  /// Limpia todas las dependencias
  static Future<void> dispose() async {
    try {
      _logger.i('🧹 Disposing all dependencies...');

      await WebSocketInjection.dispose();
      await HttpInjection.dispose();

      _getIt.reset();

      _logger.i('✅ All dependencies disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing dependencies: $e');
    }
  }

  /// Verifica si las dependencias están inicializadas
  static bool get isInitialized => _getIt.isRegistered<Logger>();
}
