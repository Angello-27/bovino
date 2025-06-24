import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_messages.dart';

// Atoms
import '../atoms/custom_button.dart';
import '../atoms/custom_text.dart';

/// Organismo para la vista de configuración
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class SettingsViewOrganism extends StatelessWidget {
  final VoidCallback? onSettingsPressed;

  const SettingsViewOrganism({super.key, this.onSettingsPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: AppColors.secondary),
          const SizedBox(height: AppUIConfig.padding),
          const TitleText(
            text: AppMessages.settings,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.margin),
          const BodyText(
            text: 'Configura los parámetros de la aplicación',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.padding * 1.5),
          CustomButton(
            text: 'Ir a Configuración',
            icon: Icons.settings,
            backgroundColor: AppColors.secondary,
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }
}
