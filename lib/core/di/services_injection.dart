import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

// Core Services
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../services/splash_service.dart';
import '../services/connectivity_service.dart';
import '../services/frame_analysis_service.dart';

/// Módulo para inyección de servicios core
/// Sigue Clean Architecture y separación de responsabilidades
class ServicesInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Configura los servicios core
  static void setup() {
    _logger.i('🔧 Setting up core services...');

    // Dio ya está registrado en HttpInjection, no lo registramos aquí
    _logger.d('✅ Dio already registered in HttpInjection');

    // Servicios core
    _getIt.registerSingleton<CameraService>(CameraService());
    _logger.d('✅ CameraService registered');

    _getIt.registerSingleton<PermissionService>(PermissionService());
    _logger.d('✅ PermissionService registered');

    _getIt.registerSingleton<SplashService>(SplashService());
    _logger.d('✅ SplashService registered');

    _getIt.registerSingleton<ConnectivityService>(ConnectivityService(_getIt<Dio>()));
    _logger.d('✅ ConnectivityService registered');

    // Servicio de análisis asíncrono de frames
    _getIt.registerSingleton<FrameAnalysisService>(
      FrameAnalysisService(_getIt<Dio>()),
    );
    _logger.d('✅ FrameAnalysisService registered');

    // Conectar CameraService con FrameAnalysisService
    final cameraService = _getIt<CameraService>();
    final frameAnalysisService = _getIt<FrameAnalysisService>();
    cameraService.setFrameAnalysisService(frameAnalysisService);
    _logger.d('✅ CameraService connected to FrameAnalysisService');

    _logger.i('🔧 Core Services configured successfully');
  }

  /// Obtiene la instancia de CameraService
  static CameraService get cameraService => _getIt<CameraService>();

  /// Obtiene la instancia de PermissionService
  static PermissionService get permissionService => _getIt<PermissionService>();

  /// Obtiene la instancia de SplashService
  static SplashService get splashService => _getIt<SplashService>();

  /// Obtiene la instancia de ConnectivityService
  static ConnectivityService get connectivityService => _getIt<ConnectivityService>();

  /// Obtiene la instancia de FrameAnalysisService
  static FrameAnalysisService get frameAnalysisService => _getIt<FrameAnalysisService>();
}
