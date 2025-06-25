import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_messages.dart';
import '../../../core/constants/app_ui_config.dart';

// Molecules
import '../molecules/home_header.dart';
import '../molecules/stats_card.dart';
import '../molecules/breeds_list.dart';
import '../molecules/theme_indicator.dart';

// Atoms
import '../atoms/custom_button.dart';

/// Organismo que contiene todo el contenido principal de la página de inicio
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class HomeContentOrganism extends StatelessWidget {
  final String? selectedBreed;
  final Function(String)? onBreedSelected;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onSettingsPressed;

  const HomeContentOrganism({
    super.key,
    this.selectedBreed,
    this.onBreedSelected,
    this.onCameraPressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppUIConfig.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header principal
          const HomeHeader(),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Estadísticas
          const StatsRow(),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Lista de razas
          BreedsList(
            selectedBreed: selectedBreed,
            onBreedSelected: onBreedSelected,
          ),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Botones de acción
          _buildActionButtons(context),

          const SizedBox(height: AppUIConfig.padding),

          // Indicador de tema
          const ThemeIndicator(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: AppMessages.cameraReady,
          icon: Icons.camera_alt,
          onPressed: onCameraPressed,
        ),
        const SizedBox(height: AppUIConfig.padding),
        CustomButton(
          text: AppMessages.settings,
          icon: Icons.settings,
          backgroundColor: AppColors.secondary,
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }
}

/// Organismo para la fila de estadísticas
class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatsCard(
            title: AppMessages.ready,
            value: '0',
            icon: Icons.analytics,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppUIConfig.margin),
        Expanded(
          child: StatsCard(
            title: AppMessages.processing,
            value: '0',
            icon: Icons.pending,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppUIConfig.margin),
        Expanded(
          child: StatsCard(
            title: AppMessages.error,
            value: '0',
            icon: Icons.error,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}
