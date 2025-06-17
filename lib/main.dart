import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/errors/failures.dart';

// Data
import 'data/datasources/remote/openai_datasource.dart';
import 'data/datasources/local/local_datasource.dart';
import 'data/repositories/bovino_repository_impl.dart';
import 'data/models/bovino_model.dart';

// Domain
import 'domain/repositories/bovino_repository.dart';
import 'domain/usecases/analizar_imagen_usecase.dart';
import 'domain/usecases/obtener_historial_usecase.dart';
import 'domain/usecases/eliminar_analisis_usecase.dart';
import 'domain/usecases/limpiar_historial_usecase.dart';

// Presentation
import 'presentation/pages/home_page.dart';
import 'presentation/providers/bovino_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar dependencias
  final dependencies = await _setupDependencies();
  
  runApp(BovinoApp(dependencies: dependencies));
}

class BovinoApp extends StatelessWidget {
  final Map<String, dynamic> dependencies;

  const BovinoApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(AppConstants.uiConfig['primaryColor']),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
            ),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.uiConfig['borderRadius']),
          ),
        ),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => BovinoProvider(
              analizarImagenUseCase: dependencies['analizarImagenUseCase'],
              obtenerHistorialUseCase: dependencies['obtenerHistorialUseCase'],
              eliminarAnalisisUseCase: dependencies['eliminarAnalisisUseCase'],
              limpiarHistorialUseCase: dependencies['limpiarHistorialUseCase'],
            ),
          ),
        ],
        child: const HomePage(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Configuración de dependencias siguiendo Clean Architecture
Future<Map<String, dynamic>> _setupDependencies() async {
  // 1. Configurar Dio para HTTP
  final dio = Dio();
  dio.options.connectTimeout = AppConstants.timeoutSeconds;
  dio.options.receiveTimeout = AppConstants.timeoutSeconds;
  dio.options.headers['Content-Type'] = 'application/json';

  // 2. Configurar SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 3. Configurar DataSources
  final remoteDataSource = OpenAIDataSource(dio);
  final localDataSource = LocalDataSourceImpl();

  // 4. Configurar Repository
  final repository = BovinoRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  // 5. Configurar Use Cases
  final analizarImagenUseCase = AnalizarImagenUseCase(repository);
  final obtenerHistorialUseCase = ObtenerHistorialUseCase(repository);
  final eliminarAnalisisUseCase = EliminarAnalisisUseCase(repository);
  final limpiarHistorialUseCase = LimpiarHistorialUseCase(repository);

  return {
    'dio': dio,
    'prefs': prefs,
    'remoteDataSource': remoteDataSource,
    'localDataSource': localDataSource,
    'repository': repository,
    'analizarImagenUseCase': analizarImagenUseCase,
    'obtenerHistorialUseCase': obtenerHistorialUseCase,
    'eliminarAnalisisUseCase': eliminarAnalisisUseCase,
    'limpiarHistorialUseCase': limpiarHistorialUseCase,
  };
}
