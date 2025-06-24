import 'dart:async';
import 'package:camera/camera.dart';
import '../constants/app_constants.dart';
import 'permission_service.dart';

/// Servicio de cámara optimizado para Android 10-15
class CameraService {
  CameraController? _controller;
  Timer? _frameCaptureTimer;
  final StreamController<String> _frameStreamController =
      StreamController<String>.broadcast();
  late PermissionService _permissionService;
  bool _isInitialized = false;
  bool _isCapturing = false;
  int _capturedFrames = 0;

  CameraService() {
    _permissionService = PermissionService();
  }

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isCapturing => _isCapturing;
  int get capturedFrames => _capturedFrames;
  Stream<String> get frameStream => _frameStreamController.stream;

  /// Inicializa la cámara con configuración optimizada para Android
  Future<void> initialize() async {
    try {
      // Verificar permisos antes de inicializar
      final permissionResult =
          await _permissionService.requestCameraPermission();
      if (!permissionResult.isGranted) {
        throw CameraException('Permission denied', permissionResult.message);
      }

      // Obtener cámaras disponibles
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException(
          'No cameras found',
          'No se encontraron cámaras disponibles',
        );
      }

      // Preferir cámara trasera para mejor calidad
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Configurar controlador con resolución alta y sin audio
      _controller = CameraController(
        camera,
        ResolutionPreset.high, // Usar resolución alta para mejor análisis
        enableAudio: false, // No necesitamos audio para análisis de frames
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      _capturedFrames = 0;
    } catch (e) {
      _isInitialized = false;
      throw CameraException(
        'Initialization error',
        'Error al inicializar la cámara: $e',
      );
    }
  }

  /// Inicia la captura automática de frames usando las constantes de la app
  Future<void> startFrameCapture({
    Duration? interval,
    int maxFrames = AppConstants.maxFramesInMemory,
  }) async {
    if (!_isInitialized || _controller == null) {
      await initialize();
    }

    if (_isCapturing) {
      return; // Ya está capturando
    }

    _isCapturing = true;
    _capturedFrames = 0;

    // Usar intervalo de las constantes o el proporcionado
    final captureInterval = interval ?? AppConstants.frameCaptureInterval;

    _frameCaptureTimer = Timer.periodic(captureInterval, (timer) async {
      // Verificar límite de frames
      if (_capturedFrames >= maxFrames) {
        await stopFrameCapture();
        return;
      }

      await _captureFrame();
    });
  }

  /// Detiene la captura automática de frames
  Future<void> stopFrameCapture() async {
    _frameCaptureTimer?.cancel();
    _frameCaptureTimer = null;
    _isCapturing = false;
  }

  /// Captura un frame individual
  Future<String?> _captureFrame() async {
    if (!_isInitialized ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return null;
    }

    try {
      final image = await _controller!.takePicture();
      _capturedFrames++;

      // Emitir el frame capturado
      _frameStreamController.add(image.path);

      return image.path;
    } catch (e) {
      // Log del error pero no interrumpir el flujo
      return null;
    }
  }

  /// Captura una imagen manual
  Future<String?> captureImage() async {
    if (!_isInitialized || _controller == null) {
      await initialize();
    }
    return await _captureFrame();
  }

  /// Obtiene información del estado de la cámara
  Map<String, dynamic> getCameraInfo() {
    if (!_isInitialized || _controller == null) {
      return {
        'isInitialized': false,
        'isCapturing': _isCapturing,
        'capturedFrames': _capturedFrames,
      };
    }

    return {
      'isInitialized': _controller!.value.isInitialized,
      'isCapturing': _isCapturing,
      'capturedFrames': _capturedFrames,
      'flashMode': _controller!.value.flashMode.toString(),
      'exposureMode': _controller!.value.exposureMode.toString(),
      'focusMode': _controller!.value.focusMode.toString(),
    };
  }

  /// Libera recursos de la cámara
  Future<void> dispose() async {
    await stopFrameCapture();
    await _controller?.dispose();
    await _frameStreamController.close();
    _isInitialized = false;
    _capturedFrames = 0;
  }
}
