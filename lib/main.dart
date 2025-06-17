import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/di/dependency_injection.dart';
import 'core/routes/app_router.dart';

// Presentation
import 'presentation/providers/bovino_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependencias
  await DependencyInjection.initialize();
  
  runApp(const BovinoApp());
}

class BovinoApp extends StatelessWidget {
  const BovinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => BovinoProvider(
                analizarImagenUseCase: DependencyInjection.analizarImagenUseCase,
                obtenerHistorialUseCase: DependencyInjection.obtenerHistorialUseCase,
                eliminarAnalisisUseCase: DependencyInjection.eliminarAnalisisUseCase,
                limpiarHistorialUseCase: DependencyInjection.limpiarHistorialUseCase,
              ),
            ),
          ],
          child: child!,
        );
      },
    );
  }
}
