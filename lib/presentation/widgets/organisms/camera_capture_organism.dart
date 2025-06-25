import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_ui_config.dart';

// Atoms
import '../atoms/custom_button.dart';
import '../atoms/custom_text.dart';
import '../atoms/custom_icon.dart';

/// Organismo para la captura de frames con la cámara
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CameraCaptureOrganism extends StatelessWidget {
  final bool isCapturing;
  final bool isConnected;
  final VoidCallback? onCapturePressed;
  final String? statusMessage;

  const CameraCaptureOrganism({
    super.key,
    this.isCapturing = false,
    this.isConnected = false,
    this.onCapturePressed,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono de cámara
          CustomIcon(
            icon: Icons.camera_alt,
            size: 80,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppUIConfig.padding),
          // Título
          const TitleText(
            text: 'Captura de Frame',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.margin),
          // Estado de conexión
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: isConnected ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              CaptionText(
                text:
                    isConnected
                        ? 'Conectado al servidor'
                        : 'Desconectado del servidor',
                color: isConnected ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppUIConfig.margin),
          // Mensaje de estado
          if (statusMessage != null)
            BodyText(text: statusMessage!, textAlign: TextAlign.center),
          const SizedBox(height: AppUIConfig.padding * 1.5),
          // Botón de captura
          CustomButton(
            text:
                isCapturing
                    ? 'Capturando frames automáticamente'
                    : 'Cámara lista para capturar frames',
            icon: Icons.camera,
            isLoading: isCapturing,
            onPressed: isCapturing ? null : onCapturePressed,
          ),
        ],
      ),
    );
  }
}
