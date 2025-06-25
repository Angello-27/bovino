import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_messages.dart';
import '../../../core/constants/app_ui_config.dart';

// Atoms
import '../atoms/custom_button.dart';
import '../atoms/custom_text.dart';

/// Organismo para la vista de cámara
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CameraViewOrganism extends StatelessWidget {
  final VoidCallback? onCameraPressed;

  const CameraViewOrganism({super.key, this.onCameraPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 80, color: AppColors.primary),
          const SizedBox(height: AppUIConfig.padding),
          const TitleText(
            text: 'Análisis con Cámara',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.margin),
          const BodyText(
            text: 'Usa la cámara para analizar ganado bovino en tiempo real',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.padding * 1.5),
          CustomButton(
            text: AppMessages.cameraReady,
            icon: Icons.camera_alt,
            onPressed: onCameraPressed,
          ),
        ],
      ),
    );
  }
}
