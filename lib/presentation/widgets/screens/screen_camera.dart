import 'package:flutter/material.dart';

// Organisms
import '../organisms/app_bar_organism.dart';
import '../organisms/camera_capture_organism.dart';

/// Screen para la página de cámara
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class ScreenCamera extends StatelessWidget {
  final bool isCapturing;
  final bool isConnected;
  final VoidCallback? onCapturePressed;
  final String? statusMessage;

  const ScreenCamera({
    super.key,
    this.isCapturing = false,
    this.isConnected = false,
    this.onCapturePressed,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarOrganism(),
      body: CameraCaptureOrganism(
        isCapturing: isCapturing,
        isConnected: isConnected,
        onCapturePressed: onCapturePressed,
        statusMessage: statusMessage,
      ),
    );
  }
}
