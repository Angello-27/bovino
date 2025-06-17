import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// Data
import '../../data/datasources/remote/openai_datasource.dart';
import '../../data/datasources/local/local_datasource.dart';
import '../../data/repositories/bovino_repository_impl.dart';

// Domain
import '../../domain/repositories/bovino_repository.dart';
import '../../domain/usecases/analizar_imagen_usecase.dart';
import '../../domain/usecases/obtener_historial_usecase.dart';
import '../../domain/usecases/eliminar_analisis_usecase.dart';
import '../../domain/usecases/limpiar_historial_usecase.dart';

/// Clase para manejo de inyección de dependencias siguiendo Clean Architecture
class DependencyInjection {
  static late Dio _dio;
  static late SharedPreferences _prefs;
  static late OpenAIDataSource _remoteDataSource;
  static late LocalDataSourceImpl _localDataSource;
  static late BovinoRepository _repository;
  static late AnalizarImagenUseCase _analizarImagenUseCase;
  static late ObtenerHistorialUseCase _obtenerHistorialUseCase;
  static late EliminarAnalisisUseCase _eliminarAnalisisUseCase;
  static late LimpiarHistorialUseCase _limpiarHistorialUseCase;

  /// Inicializa todas las dependencias
  static Future<void> initialize() async {
    await _setupHttpClient();
    await _setupSharedPreferences();
    await _setupDataSources();
    await _setupRepository();
    await _setupUseCases();
  }

  /// Configura el cliente HTTP (Dio)
  static Future<void> _setupHttpClient() async {
    _dio = Dio();
    _dio.options.connectTimeout = AppConstants.timeoutSeconds;
    _dio.options.receiveTimeout = AppConstants.timeoutSeconds;
    _dio.options.headers['Content-Type'] = 'application/json';
    
    // Configurar interceptores para logging (solo en debug)
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('🌐 HTTP Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ HTTP Response: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Configura SharedPreferences
  static Future<void> _setupSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Configura las fuentes de datos
  static Future<void> _setupDataSources() async {
    _remoteDataSource = OpenAIDataSource(_dio);
    _localDataSource = LocalDataSourceImpl();
  }

  /// Configura el repositorio
  static Future<void> _setupRepository() async {
    _repository = BovinoRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );
  }

  /// Configura los casos de uso
  static Future<void> _setupUseCases() async {
    _analizarImagenUseCase = AnalizarImagenUseCase(_repository);
    _obtenerHistorialUseCase = ObtenerHistorialUseCase(_repository);
    _eliminarAnalisisUseCase = EliminarAnalisisUseCase(_repository);
    _limpiarHistorialUseCase = LimpiarHistorialUseCase(_repository);
  }

  /// Getters para acceder a las dependencias
  static Dio get dio => _dio;
  static SharedPreferences get prefs => _prefs;
  static OpenAIDataSource get remoteDataSource => _remoteDataSource;
  static LocalDataSourceImpl get localDataSource => _localDataSource;
  static BovinoRepository get repository => _repository;
  static AnalizarImagenUseCase get analizarImagenUseCase => _analizarImagenUseCase;
  static ObtenerHistorialUseCase get obtenerHistorialUseCase => _obtenerHistorialUseCase;
  static EliminarAnalisisUseCase get eliminarAnalisisUseCase => _eliminarAnalisisUseCase;
  static LimpiarHistorialUseCase get limpiarHistorialUseCase => _limpiarHistorialUseCase;

  /// Obtiene todas las dependencias como un mapa (para compatibilidad)
  static Map<String, dynamic> get dependencies => {
    'dio': _dio,
    'prefs': _prefs,
    'remoteDataSource': _remoteDataSource,
    'localDataSource': _localDataSource,
    'repository': _repository,
    'analizarImagenUseCase': _analizarImagenUseCase,
    'obtenerHistorialUseCase': _obtenerHistorialUseCase,
    'eliminarAnalisisUseCase': _eliminarAnalisisUseCase,
    'limpiarHistorialUseCase': _limpiarHistorialUseCase,
  };

  /// Limpia las dependencias (útil para testing)
  static void dispose() {
    _dio.close();
  }
} 