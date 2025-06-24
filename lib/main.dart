import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/theme/theme_manager.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_router.dart';

// Presentation
import 'presentation/blocs/theme_bloc.dart';
import 'presentation/widgets/molecules/theme_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar logger
  Logger.level = Level.debug;

  // Inicializar dependencias
  await DependencyInjection.initialize();

  runApp(const BovinoApp());
}

class BovinoApp extends StatelessWidget {
  const BovinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create:
              (context) =>
                  DependencyInjection.themeBloc
                    ..add(const InitializeThemeEvent()),
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
                return ThemeErrorWidget(errorState: state);
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
