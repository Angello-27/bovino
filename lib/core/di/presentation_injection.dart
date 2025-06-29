import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Presentation
import '../../presentation/blocs/camera_bloc.dart';
import '../../presentation/blocs/bovino_bloc.dart';
import '../../presentation/blocs/theme_bloc.dart';
import '../../presentation/blocs/splash_bloc.dart';

// Services
import '../services/camera_service.dart';
import '../services/splash_service.dart';

// Data
import '../../domain/repositories/bovino_repository.dart';

/// Módulo para inyección de dependencias de presentación
/// Sigue Clean Architecture y separación de responsabilidades
class PresentationInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Configura los BLoCs
  static Future<void> setup() async {
    // Obtener dependencias desde GetIt después de que estén registradas
    final cameraService = _getIt<CameraService>();
    final splashService = _getIt<SplashService>();
    final repository = _getIt<BovinoRepository>();

    _getIt.registerFactory<CameraBloc>(
      () => CameraBloc(cameraService: cameraService),
    );

    _getIt.registerFactory<BovinoBloc>(
      () => BovinoBloc(repository: repository),
    );

    _getIt.registerFactory<ThemeBloc>(() => ThemeBloc());

    _getIt.registerFactory<SplashBloc>(
      () => SplashBloc(splashService: splashService),
    );

    _logger.i('🔧 Presentation Layer configured successfully');
  }

  /// Obtiene la instancia de CameraBloc
  static CameraBloc get cameraBloc => _getIt<CameraBloc>();

  /// Obtiene la instancia de BovinoBloc
  static BovinoBloc get bovinoBloc => _getIt<BovinoBloc>();

  /// Obtiene la instancia de ThemeBloc
  static ThemeBloc get themeBloc => _getIt<ThemeBloc>();

  /// Obtiene la instancia de SplashBloc
  static SplashBloc get splashBloc => _getIt<SplashBloc>();
}
