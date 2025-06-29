import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

// DI Modules
import 'http_injection.dart';
import 'services_injection.dart';
import 'data_injection.dart';
import 'presentation_injection.dart';

// Services
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../services/splash_service.dart';
import '../services/connectivity_service.dart';
import '../services/frame_analysis_service.dart';

// BLoCs
import '../../presentation/blocs/camera_bloc.dart';
import '../../presentation/blocs/bovino_bloc.dart';
import '../../presentation/blocs/theme_bloc.dart';
import '../../presentation/blocs/splash_bloc.dart';

// Repositories
import '../../domain/repositories/bovino_repository.dart';

/// Coordinador principal para inyección de dependencias
/// Sigue Clean Architecture y separación de responsabilidades
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Inicializa todas las dependencias en orden correcto
  static Future<void> initialize() async {
    _logger.i('🚀 Starting dependency injection...');

    try {
      // 1. Configurar infraestructura (HTTP, WebSocket)
      await _initializeInfrastructure();

      // 2. Configurar servicios core
      await _initializeServices();

      // 3. Configurar capa de datos
      await _initializeData();

      // 4. Configurar capa de presentación
      await _initializePresentation();

      _logger.i('✅ All dependencies initialized successfully');
    } catch (e) {
      _logger.e('❌ Error initializing dependencies: $e');
      rethrow;
    }
  }

  /// Inicializa la infraestructura con manejo de errores
  static Future<void> _initializeInfrastructure() async {
    _logger.i('🔧 Initializing infrastructure...');

    try {
      await HttpInjection.setup();
      _logger.i('✅ HTTP infrastructure initialized');
    } catch (e) {
      _logger.e('❌ HTTP initialization failed: $e');
    }
  }

  /// Inicializa los servicios core con manejo de errores
  static Future<void> _initializeServices() async {
    _logger.i('🔧 Initializing core services...');

    try {
      ServicesInjection.setup();
      _logger.i('✅ Core services initialized');
    } catch (e) {
      _logger.e('❌ Services initialization failed: $e');
      rethrow; // Los servicios core son críticos
    }
  }

  /// Inicializa la capa de datos con manejo de errores
  static Future<void> _initializeData() async {
    _logger.i('📊 Initializing data layer...');

    try {
      await DataInjection.setup();
      _logger.i('✅ Data layer initialized');
    } catch (e) {
      _logger.e('❌ Data layer initialization failed: $e');
    }
  }

  /// Inicializa la capa de presentación con manejo de errores
  static Future<void> _initializePresentation() async {
    _logger.i('🎨 Initializing presentation layer...');

    try {
      await PresentationInjection.setup();
      _logger.i('✅ Presentation layer initialized');
    } catch (e) {
      _logger.e('❌ Presentation layer initialization failed: $e');
    }
  }

  /// Getters delegados a los módulos específicos
  // HTTP
  static Dio get dio => _getIt<Dio>();

  // Services
  static CameraService get cameraService => ServicesInjection.cameraService;
  static PermissionService get permissionService => ServicesInjection.permissionService;
  static SplashService get splashService => ServicesInjection.splashService;
  static ConnectivityService get connectivityService => ServicesInjection.connectivityService;
  static FrameAnalysisService get frameAnalysisService => ServicesInjection.frameAnalysisService;

  // Data
  static BovinoRepository get bovinoRepository => _getIt<BovinoRepository>();

  // Presentation - Getters robustos con fallbacks
  static CameraBloc get cameraBloc {
    try {
      return _getIt<CameraBloc>();
    } catch (e) {
      _logger.w('⚠️ CameraBloc no disponible, creando nuevo');
      return CameraBloc(cameraService: cameraService);
    }
  }

  static BovinoBloc get bovinoBloc {
    try {
      return _getIt<BovinoBloc>();
    } catch (e) {
      _logger.w('⚠️ BovinoBloc no disponible, creando nuevo');
      return BovinoBloc(repository: bovinoRepository);
    }
  }

  static ThemeBloc get themeBloc {
    try {
      return _getIt<ThemeBloc>();
    } catch (e) {
      _logger.w('⚠️ ThemeBloc no disponible, creando nuevo');
      return ThemeBloc();
    }
  }

  static SplashBloc get splashBloc {
    try {
      return _getIt<SplashBloc>();
    } catch (e) {
      _logger.w('⚠️ SplashBloc no disponible, creando nuevo');
      return SplashBloc(splashService: splashService);
    }
  }

  /// Limpia todas las dependencias
  static Future<void> dispose() async {
    try {
      _logger.i('🧹 Disposing all dependencies...');

      await HttpInjection.dispose();

      _getIt.reset();

      _logger.i('✅ All dependencies disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing dependencies: $e');
    }
  }

  /// Verifica si las dependencias están inicializadas
  static bool get isInitialized => _getIt.isRegistered<Logger>();

  /// Resetear todas las dependencias (útil para testing)
  static Future<void> reset() async {
    await _getIt.reset();
    _logger.i('🔄 Dependencies reset');
  }
}
