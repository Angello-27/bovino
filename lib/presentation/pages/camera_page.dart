import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import '../../core/constants/app_messages.dart';
import '../../core/di/dependency_injection.dart';

// Screens
import '../widgets/screens/screen_camera.dart';

// BLoCs
import '../blocs/camera_bloc.dart';

/// Página para captura y análisis de imágenes
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late final CameraBloc _cameraBloc;

  @override
  void initState() {
    super.initState();
    _cameraBloc = DependencyInjection.cameraBloc;
    _cameraBloc.add(InitializeCamera());
  }

  @override
  void dispose() {
    _cameraBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CameraBloc>.value(
      value: _cameraBloc,
      child: BlocBuilder<CameraBloc, CameraState>(
        builder: (context, state) {
          bool isCapturing = state is CameraCapturing;
          bool isConnected = state is CameraReady || state is CameraCapturing;
          String? statusMessage;

          if (state is CameraLoading) {
            statusMessage = AppMessages.cameraInitializing;
          } else if (state is CameraError) {
            statusMessage = state.failure.message;
          } else if (state is CameraCapturing) {
            statusMessage = AppMessages.capturingFrames;
          } else if (state is CameraReady) {
            statusMessage = AppMessages.cameraReady;
          }

          return ScreenCamera(
            isCapturing: isCapturing,
            isConnected: isConnected,
            statusMessage: statusMessage,
            onCapturePressed: _onCapturePressed,
          );
        },
      ),
    );
  }

  void _onCapturePressed() {
    _cameraBloc.add(StartCapture());
  }
}
