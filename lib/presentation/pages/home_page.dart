import 'package:flutter/material.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_messages.dart';
import '../../core/routes/app_router.dart';

// Atoms
import '../widgets/atoms/custom_icon.dart';
import '../widgets/atoms/custom_text.dart';
import '../widgets/atoms/custom_button.dart';

// Molecules
import '../widgets/molecules/theme_toggle_button.dart';
import '../widgets/molecules/theme_indicator.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText(text: 'Bovino IA'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
        elevation: AppUIConfig.appBarElevation,
        actions: const [
          // Botón de cambio de tema usando widget molecular
          ThemeToggleButton(),
          IconButton(
            icon: CustomIcon(icon: Icons.settings),
            tooltip: 'Configuración',
            onPressed: null, // Se maneja en el body
          ),
        ],
      ),
      body: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppUIConfig.padding),
      child: Column(
        children: [
          // Header informativo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppUIConfig.padding),
              child: Column(
                children: [
                  const CustomIcon(
                    icon: Icons.camera_alt,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppUIConfig.margin),
                  const TitleText(
                    text: 'Bovino IA - Reconocimiento de Ganado',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppUIConfig.margin / 2),
                  const BodyText(
                    text:
                        'Utiliza inteligencia artificial para identificar razas bovinas',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Botones de navegación
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Iniciar Cámara',
                  icon: Icons.camera_alt,
                  onPressed: () => AppRouter.goToCamera(context),
                ),
                const SizedBox(height: AppUIConfig.padding),
                CustomButton(
                  text: 'Configuración',
                  icon: Icons.settings,
                  backgroundColor: AppColors.secondary,
                  onPressed: () => AppRouter.goToSettings(context),
                ),
              ],
            ),
          ),

          // Indicador de tema actual usando widget molecular
          const ThemeIndicator(),
        ],
      ),
    );
  }
}
