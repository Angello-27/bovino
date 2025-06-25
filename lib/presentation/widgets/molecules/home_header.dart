import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_ui_config.dart';

import '../atoms/custom_text.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppUIConfig.padding),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
        boxShadow: AppUIConfig.cardShadow,
      ),
      child: Column(
        children: [
          // Icono principal
          Container(
            padding: const EdgeInsets.all(AppUIConfig.padding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 48, color: Colors.white),
          ),

          const SizedBox(height: AppUIConfig.padding),

          // Título principal
          const TitleText(
            text: AppConstants.appName,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppUIConfig.margin),

          // Descripción
          const BodyText(
            text: AppConstants.appDescription,
            color: Colors.white,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppUIConfig.padding),

          // Información adicional
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppUIConfig.padding,
              vertical: AppUIConfig.margin,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 20),
                const SizedBox(width: AppUIConfig.margin),
                const CaptionText(
                  text: 'Análisis con IA y estimación de peso',
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
