import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/theme/theme_manager.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_router.dart';

// Presentation
import 'presentation/blocs/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar logger
  Logger.level = Level.debug;

  try {
    // Inicializar solo dependencias críticas para el lanzamiento
    await DependencyInjection.initializeCritical();
    Logger().i('✅ Dependencias críticas inicializadas correctamente');
  } catch (e, stackTrace) {
    Logger().e('❌ Error crítico en inicialización: $e');
    Logger().e('Stack trace: $stackTrace');
    // Continuar con la app aunque haya errores
  }

  runApp(const BovinoApp());
}

class BovinoApp extends StatelessWidget {
  const BovinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => _getThemeBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: state is ThemeLoaded ? state.theme : ThemeManager.lightTheme,
            darkTheme: ThemeManager.darkTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              // Manejar errores de tema usando widget dedicado
              if (state is ThemeError) {
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
    try {
      // Intentar obtener ThemeBloc desde GetIt
      if (GetIt.instance.isRegistered<ThemeBloc>()) {
        final themeBloc = GetIt.instance<ThemeBloc>();
        Logger().i('✅ ThemeBloc obtenido desde GetIt en main');
        themeBloc.add(const InitializeThemeEvent());
        return themeBloc;
      } else {
        // Fallback: crear ThemeBloc manualmente
        Logger().w('⚠️ ThemeBloc no registrado en GetIt, creando manualmente en main');
        final themeBloc = ThemeBloc();
        themeBloc.add(const InitializeThemeEvent());
        return themeBloc;
      }
    } catch (e) {
      Logger().e('❌ Error al obtener ThemeBloc en main: $e');
      // Fallback final
      final themeBloc = ThemeBloc();
      themeBloc.add(const InitializeThemeEvent());
      return themeBloc;
    }
  }
}
