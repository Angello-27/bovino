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
import '../../presentation/blocs/connectivity_bloc.dart';

// Repositories
import '../../domain/repositories/bovino_repository.dart';

// Data Sources
import '../../data/datasources/remote/tensorflow_server_datasource.dart';

/// Coordinador principal para inyección de dependencias
/// Sigue Clean Architecture y separación de responsabilidades
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Inicializa todas las dependencias en orden correcto
  static Future<void> initialize() async {
    _logger.i('🚀 Starting dependency injection...');

    try {
      // 1. Configurar infraestructura (HTTP)
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

  /// Inicializa solo las dependencias críticas para el lanzamiento rápido
  static Future<void> initializeCritical() async {
    _logger.i('⚡ Starting critical dependency injection...');

    try {
      // 1. Solo infraestructura básica (HTTP)
      await _initializeInfrastructure();

      // 2. Solo servicios esenciales (sin cámara ni conectividad)
      _initializeEssentialServices();

      // 3. Capa de datos básica
      await _initializeData();

      // 4. Solo BLoCs esenciales
      _initializeEssentialPresentation();

      _logger.i('✅ Critical dependencies initialized successfully');
    } catch (e) {
      _logger.e('❌ Error initializing critical dependencies: $e');
      // No rethrow para permitir que la app continúe
    }
  }

  /// Inicializa solo servicios esenciales (sin cámara ni conectividad)
  static void _initializeEssentialServices() {
    _logger.i('🔧 Setting up essential services...');

    // Solo servicios que no requieren hardware o red
    _getIt.registerSingleton<SplashService>(SplashService());
    _logger.d('✅ SplashService registered');

    _logger.i('🔧 Essential Services configured successfully');
  }

  /// Inicializa solo la presentación esencial
  static void _initializeEssentialPresentation() {
    _logger.i('🎨 Setting up essential presentation...');

    try {
      // Solo BLoCs esenciales
      _getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
      _logger.d('✅ ThemeBloc registered');

      _getIt.registerFactory<SplashBloc>(() => SplashBloc(splashService: _getIt<SplashService>()));
      _logger.d('✅ SplashBloc registered');

      _logger.i('🎨 Essential presentation configured successfully');
    } catch (e) {
      _logger.e('❌ Essential presentation initialization failed: $e');
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
      return CameraBloc(
        cameraService: cameraService,
        bovinoBloc: bovinoBloc,
      );
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

  static ConnectivityBloc get connectivityBloc {
    try {
      return _getIt<ConnectivityBloc>();
    } catch (e) {
      _logger.w('⚠️ ConnectivityBloc no disponible, creando nuevo');
      return ConnectivityBloc(connectivityService: connectivityService);
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

  /// Inicializa las dependencias pesadas de forma asíncrona (para usar en splash screen)
  static Future<void> initializeHeavyDependencies() async {
    _logger.i('🏋️ Starting heavy dependency injection...');

    try {
      // 1. Inicializar servicios pesados (cámara, conectividad)
      await _initializeHeavyServices();

      // 2. Inicializar BLoCs pesados
      await _initializeHeavyPresentation();

      _logger.i('✅ Heavy dependencies initialized successfully');
    } catch (e) {
      _logger.e('❌ Error initializing heavy dependencies: $e');
      // No rethrow para permitir que la app continúe
    }
  }

  /// Inicializa servicios pesados (cámara, conectividad)
  static Future<void> _initializeHeavyServices() async {
    _logger.i('🔧 Setting up heavy services...');

    try {
      // CameraService (puede tardar en inicializar)
      _getIt.registerSingleton<CameraService>(CameraService());
      _logger.d('✅ CameraService registered');

      // PermissionService
      _getIt.registerSingleton<PermissionService>(PermissionService());
      _logger.d('✅ PermissionService registered');

      // ConnectivityService (puede tardar en verificar servidor)
      _getIt.registerSingleton<ConnectivityService>(ConnectivityService(_getIt<Dio>()));
      _logger.d('✅ ConnectivityService registered');

      // FrameAnalysisService
      _getIt.registerSingleton<FrameAnalysisService>(
        FrameAnalysisService(_getIt<TensorFlowServerDataSource  >()),
      );
      _logger.d('✅ FrameAnalysisService registered');

      // Conectar CameraService con FrameAnalysisService
      final cameraService = _getIt<CameraService>();
      final frameAnalysisService = _getIt<FrameAnalysisService>();
      cameraService.setFrameAnalysisService(frameAnalysisService);
      _logger.d('✅ CameraService connected to FrameAnalysisService');

      _logger.i('🔧 Heavy Services configured successfully');
    } catch (e) {
      _logger.e('❌ Heavy services initialization failed: $e');
    }
  }

  /// Inicializa BLoCs pesados
  static Future<void> _initializeHeavyPresentation() async {
    _logger.i('🎨 Setting up heavy presentation...');

    try {
      // BLoCs que requieren servicios pesados
      _getIt.registerFactory<CameraBloc>(() => CameraBloc(
        cameraService: _getIt<CameraService>(),
        bovinoBloc: _getIt<BovinoBloc>(),
      ));
      _logger.d('✅ CameraBloc registered');

      _getIt.registerFactory<BovinoBloc>(() => BovinoBloc(repository: _getIt<BovinoRepository>()));
      _logger.d('✅ BovinoBloc registered');

      _logger.i('🎨 Heavy presentation configured successfully');
    } catch (e) {
      _logger.e('❌ Heavy presentation initialization failed: $e');
    }
  }
}
