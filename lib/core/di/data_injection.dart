import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Data
import '../../data/datasources/remote/tensorflow_server_datasource.dart';
import '../../data/datasources/remote/tensorflow_server_datasource_impl.dart'
    as impl;
import '../../data/repositories/bovino_repository_impl.dart';

// Domain
import '../../domain/repositories/bovino_repository.dart';

// DI Modules
import 'http_injection.dart';
import 'websocket_injection.dart';

/// Módulo para inyección de dependencias de datos
/// Sigue Clean Architecture y separación de responsabilidades
class DataInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Configura las fuentes de datos
  static Future<void> setupDataSources() async {
    final dio = HttpInjection.dio;
    final websocket = WebSocketInjection.websocket;

    _getIt.registerSingleton<TensorFlowServerDataSource>(
      impl.TensorFlowServerDataSourceImpl(dio, websocket),
    );

    _logger.i('🔧 Data Sources configured successfully');
  }

  /// Configura el repositorio
  static Future<void> setupRepository() async {
    final remoteDataSource = _getIt<TensorFlowServerDataSource>();

    _getIt.registerSingleton<BovinoRepository>(
      BovinoRepositoryImpl(remoteDataSource: remoteDataSource),
    );

    _logger.i('🔧 Repository configured successfully');
  }

  /// Configura todas las dependencias de datos
  static Future<void> setup() async {
    await setupDataSources();
    await setupRepository();
  }

  /// Obtiene la instancia de TensorFlowServerDataSource
  static TensorFlowServerDataSource get remoteDataSource =>
      _getIt<TensorFlowServerDataSource>();

  /// Obtiene la instancia de BovinoRepository
  static BovinoRepository get repository => _getIt<BovinoRepository>();
}
