import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

// Core Services
import '../services/camera_service.dart';
import '../services/permission_service.dart';

// Data
import '../../data/datasources/remote/tensorflow_server_datasource.dart';
import '../../data/datasources/remote/tensorflow_server_datasource_impl.dart'
    as impl;
import '../../data/repositories/bovino_repository_impl.dart';

// Domain
import '../../domain/repositories/bovino_repository.dart';

// Presentation
import '../../presentation/blocs/camera_bloc.dart';
import '../../presentation/blocs/bovino_bloc.dart';
import '../../presentation/blocs/theme_bloc.dart';

/// Clase para manejo de inyección de dependencias siguiendo Clean Architecture
class DependencyInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Inicializa todas las dependencias
  static Future<void> initialize() async {
    await _setupHttpClient();
    await _setupWebSocket();
    await _setupServices();
    await _setupDataSources();
    await _setupRepository();
    await _setupBlocs();
  }

  /// Configura el cliente HTTP (Dio)
  static Future<void> _setupHttpClient() async {
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
  }

  /// Configura WebSocket para notificaciones asíncronas
  static Future<void> _setupWebSocket() async {
    try {
      final channel = WebSocketChannel.connect(
        Uri.parse(AppConstants.websocketUrl),
      );

      _getIt.registerSingleton<WebSocketChannel>(channel);
      _logger.i('🔌 WebSocket Connected to ${AppConstants.websocketUrl}');
    } catch (e) {
      _logger.e('❌ WebSocket Connection Error: $e');
      // Registrar un WebSocket mock para evitar errores
      _getIt.registerSingleton<WebSocketChannel>(
        WebSocketChannel.connect(Uri.parse('ws://localhost')),
      );
    }
  }

  /// Configura los servicios core
  static Future<void> _setupServices() async {
    _getIt.registerSingleton<CameraService>(CameraService());
    _getIt.registerSingleton<PermissionService>(PermissionService());
  }

  /// Configura las fuentes de datos
  static Future<void> _setupDataSources() async {
    final dio = _getIt<Dio>();
    final websocket = _getIt<WebSocketChannel>();

    _getIt.registerSingleton<TensorFlowServerDataSource>(
      impl.TensorFlowServerDataSourceImpl(dio, websocket),
    );
  }

  /// Configura el repositorio
  static Future<void> _setupRepository() async {
    final remoteDataSource = _getIt<TensorFlowServerDataSource>();

    _getIt.registerSingleton<BovinoRepository>(
      BovinoRepositoryImpl(remoteDataSource: remoteDataSource),
    );
  }

  /// Configura los BLoCs
  static Future<void> _setupBlocs() async {
    final cameraService = _getIt<CameraService>();
    final repository = _getIt<BovinoRepository>();

    _getIt.registerFactory<CameraBloc>(
      () => CameraBloc(cameraService: cameraService),
    );

    _getIt.registerFactory<BovinoBloc>(
      () => BovinoBloc(repository: repository),
    );

    _getIt.registerFactory<ThemeBloc>(() => ThemeBloc());
  }

  /// Getters para acceder a las dependencias
  static Dio get dio => _getIt<Dio>();
  static WebSocketChannel get websocket => _getIt<WebSocketChannel>();
  static CameraService get cameraService => _getIt<CameraService>();
  static PermissionService get permissionService => _getIt<PermissionService>();
  static TensorFlowServerDataSource get remoteDataSource =>
      _getIt<TensorFlowServerDataSource>();
  static BovinoRepository get repository => _getIt<BovinoRepository>();
  static CameraBloc get cameraBloc => _getIt<CameraBloc>();
  static BovinoBloc get bovinoBloc => _getIt<BovinoBloc>();
  static ThemeBloc get themeBloc => _getIt<ThemeBloc>();

  /// Obtiene todas las dependencias como un mapa (para compatibilidad)
  static Map<String, dynamic> get dependencies => {
    'dio': dio,
    'websocket': websocket,
    'cameraService': cameraService,
    'permissionService': permissionService,
    'remoteDataSource': remoteDataSource,
    'repository': repository,
    'cameraBloc': cameraBloc,
    'bovinoBloc': bovinoBloc,
    'themeBloc': themeBloc,
  };

  /// Limpia las dependencias (útil para testing)
  static Future<void> dispose() async {
    try {
      final websocket = _getIt<WebSocketChannel>();
      await websocket.sink.close();
    } catch (e) {
      _logger.e('Error closing WebSocket: $e');
    }

    try {
      final dio = _getIt<Dio>();
      dio.close();
    } catch (e) {
      _logger.e('Error closing Dio: $e');
    }

    _getIt.reset();
  }

  /// Verifica si las dependencias están inicializadas
  static bool get isInitialized => _getIt.isRegistered<Dio>();
}
