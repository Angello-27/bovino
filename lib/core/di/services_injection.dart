import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Core Services
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../services/splash_service.dart';

/// Módulo para inyección de servicios core
/// Sigue Clean Architecture y separación de responsabilidades
class ServicesInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Configura los servicios core
  static Future<void> setup() async {
    _getIt.registerSingleton<CameraService>(CameraService());
    _getIt.registerSingleton<PermissionService>(PermissionService());
    _getIt.registerSingleton<SplashService>(SplashService());

    _logger.i('🔧 Core Services configured successfully');
  }

  /// Obtiene la instancia de CameraService
  static CameraService get cameraService => _getIt<CameraService>();

  /// Obtiene la instancia de PermissionService
  static PermissionService get permissionService => _getIt<PermissionService>();

  /// Obtiene la instancia de SplashService
  static SplashService get splashService => _getIt<SplashService>();
}
