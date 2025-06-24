import 'package:flutter/material.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_messages.dart';

// Atoms
import '../widgets/atoms/custom_icon.dart';
import '../widgets/atoms/custom_text.dart';

// Molecules
import '../widgets/molecules/theme_toggle_button.dart';

/// Página para captura y análisis de imágenes
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText(text: 'Cámara'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
        elevation: AppUIConfig.appBarElevation,
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIcon(
              icon: Icons.camera_alt,
              size: 80,
              color: AppColors.primary,
            ),
            SizedBox(height: AppUIConfig.padding),
            TitleText(
              text: 'Cámara - En desarrollo',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppUIConfig.margin),
            BodyText(
              text: 'Aquí se implementará la captura y análisis de imágenes',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
