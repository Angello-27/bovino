import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_messages.dart';
import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_router.dart';

// Screens
import '../widgets/screens/screen_home.dart';

// BLoCs
import '../blocs/theme_bloc.dart';

/// Página principal de la aplicación
/// Maneja los BLoCs y la lógica de negocio
/// Usa el screen para la estructura UI siguiendo Atomic Design
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _selectedBreed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (context) => DependencyInjection.themeBloc,
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ScreenHome(
            currentIndex: _currentIndex,
            selectedBreed: _selectedBreed,
            onBreedSelected: _onBreedSelected,
            onNavigationTap: _onNavigationTap,
            onCameraPressed: _onCameraPressed,
            onSettingsPressed: _onSettingsPressed,
          );
        },
      ),
    );
  }

  /// Maneja la selección de raza
  void _onBreedSelected(String breed) {
    setState(() {
      _selectedBreed = breed;
    });

    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${AppMessages.bovinoDetected}: $breed'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  /// Maneja la navegación entre vistas
  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Maneja la navegación a la cámara
  void _onCameraPressed() {
    AppRouter.goToCamera(context);
  }

  /// Maneja la navegación a configuración
  void _onSettingsPressed() {
    AppRouter.goToSettings(context);
  }
}
