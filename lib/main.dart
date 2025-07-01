import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/theme/theme_manager.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_router.dart';
import 'core/services/splash_service.dart';

// Presentation
import 'presentation/blocs/theme_bloc.dart';
import 'presentation/blocs/splash_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar logger con nivel debug para ver todos los mensajes
  Logger.level = Level.debug;
  final logger = Logger();
  
  logger.i('🚀 Iniciando aplicación Bovino IA...');
  logger.i('📱 Versión: ${AppConstants.appVersion}');
  logger.i('🌐 Servidor: ${AppConstants.serverBaseUrl}');

  try {
    // Inicializar dependencias críticas
    logger.i('🔧 Inicializando dependencias críticas...');
    await DependencyInjection.initializeCritical();
    logger.i('✅ Dependencias críticas inicializadas correctamente');
    
    // Inicializar dependencias completas en background
    logger.i('🔧 Inicializando dependencias completas en background...');
    DependencyInjection.initialize().then((_) {
      logger.i('✅ Todas las dependencias inicializadas correctamente');
    }).catchError((e) {
      logger.e('❌ Error al inicializar dependencias completas: $e');
    });
    
  } catch (e, stackTrace) {
    logger.e('❌ Error crítico en inicialización: $e');
    logger.e('Stack trace: $stackTrace');
    // Continuar con la app aunque haya errores
  }

  runApp(const BovinoApp());
}

class BovinoApp extends StatelessWidget {
  const BovinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = Logger();
    logger.i('🎨 Construyendo aplicación...');
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => _getThemeBloc(),
        ),
        BlocProvider<SplashBloc>(
          create: (context) => _getSplashBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          logger.d('🎨 Estado del tema: $state');
          
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: state is ThemeLoaded ? state.theme : ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              // Manejar errores de tema usando widget dedicado
              if (state is ThemeError) {
                logger.e('❌ Error de tema detectado');
                return const Center(child: Text('Error de tema'));
              }
              return child!;
            },
          );
        },
      ),
    );
  }

  /// Obtiene ThemeBloc con manejo robusto de errores
  ThemeBloc _getThemeBloc() {
    final logger = Logger();
    try {
      // Intentar obtener ThemeBloc desde GetIt
      if (GetIt.instance.isRegistered<ThemeBloc>()) {
        final themeBloc = GetIt.instance<ThemeBloc>();
        logger.i('✅ ThemeBloc obtenido desde GetIt en main');
        themeBloc.add(const InitializeThemeEvent());
        return themeBloc;
      } else {
        // Fallback: crear ThemeBloc manualmente
        logger.w('⚠️ ThemeBloc no registrado en GetIt, creando manualmente en main');
        final themeBloc = ThemeBloc();
        themeBloc.add(const InitializeThemeEvent());
        return themeBloc;
      }
    } catch (e) {
      logger.e('❌ Error al obtener ThemeBloc en main: $e');
      // Fallback final
      final themeBloc = ThemeBloc();
      themeBloc.add(const InitializeThemeEvent());
      return themeBloc;
    }
  }

  /// Obtiene SplashBloc con manejo robusto de errores
  SplashBloc _getSplashBloc() {
    final logger = Logger();
    try {
      // Intentar obtener SplashBloc desde GetIt
      if (GetIt.instance.isRegistered<SplashBloc>()) {
        final splashBloc = GetIt.instance<SplashBloc>();
        logger.i('✅ SplashBloc obtenido desde GetIt en main');
        splashBloc.add(const InitializeSplash());
        return splashBloc;
      } else {
        // Fallback: crear SplashBloc manualmente
        logger.w('⚠️ SplashBloc no registrado en GetIt, creando manualmente en main');
        final splashService = GetIt.instance.isRegistered<SplashService>() 
            ? GetIt.instance<SplashService>() 
            : SplashService();
        final splashBloc = SplashBloc(splashService: splashService);
        splashBloc.add(const InitializeSplash());
        return splashBloc;
      }
    } catch (e) {
      logger.e('❌ Error al obtener SplashBloc en main: $e');
      // Fallback final
      final splashBloc = SplashBloc(splashService: SplashService());
      splashBloc.add(const InitializeSplash());
      return splashBloc;
    }
  }
}
