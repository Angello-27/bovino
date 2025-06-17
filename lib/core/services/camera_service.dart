import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import 'permission_service.dart';

class CameraService {
  CameraController? _controller;
  Timer? _frameCaptureTimer;
  final StreamController<String> _frameStreamController = StreamController<String>.broadcast();
  final StreamController<CameraException> _errorStreamController = StreamController<CameraException>.broadcast();
  final StreamController<PermissionResult> _permissionStreamController = StreamController<PermissionResult>.broadcast();
  
  late PermissionService _permissionService;
  bool _isInitialized = false;
  bool _isCapturing = false;
  int _capturedFrames = 0;
  DateTime? _lastCaptureTime;

  CameraService() {
    _permissionService = PermissionService();
  }

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isCapturing => _isCapturing;
  int get capturedFrames => _capturedFrames;
  Stream<String> get frameStream => _frameStreamController.stream;
  Stream<CameraException> get errorStream => _errorStreamController.stream;
  Stream<PermissionResult> get permissionStream => _permissionStreamController.stream;

  /// Inicializa la cámara con verificación de permisos
  Future<void> initialize() async {
    try {
      // Verificar permisos antes de inicializar
      final permissionResult = await _permissionService.requestCameraPermission();
      
      if (!permissionResult.isGranted) {
        _permissionStreamController.add(permissionResult);
        throw CameraException(
          'Permission denied',
          permissionResult.message,
        );
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('No cameras found', 'No se encontraron cámaras disponibles');
      }

      // Preferir cámara trasera
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false, // No necesitamos audio para análisis
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
      
      // Emitir resultado exitoso
      _permissionStreamController.add(PermissionResult(
        isGranted: true,
        permission: Permission.camera,
        message: 'Cámara inicializada correctamente',
      ));
    } catch (e) {
      _errorStreamController.add(CameraException(
        'Initialization error',
        'Error al inicializar la cámara: $e',
      ));
      rethrow;
    }
  }

  /// Verifica permisos sin inicializar la cámara
  Future<PermissionResult> checkPermissions() async {
    return await _permissionService.checkAllPermissions();
  }

  /// Solicita permisos específicos
  Future<PermissionResult> requestCameraPermission() async {
    return await _permissionService.requestCameraPermission();
  }

  /// Solicita permisos de almacenamiento
  Future<PermissionResult> requestStoragePermission() async {
    return await _permissionService.requestStoragePermission();
  }

  /// Inicia la captura automática de frames con verificación de permisos
  Future<void> startFrameCapture({
    Duration interval = const Duration(seconds: 3),
    int maxFrames = 10,
  }) async {
    if (!_isInitialized || _controller == null) {
      // Intentar inicializar si no está inicializada
      await initialize();
    }

    if (_isCapturing) {
      return; // Ya está capturando
    }

    _isCapturing = true;
    _capturedFrames = 0;
    _lastCaptureTime = null;

    // Iniciar timer para captura automática
    _frameCaptureTimer = Timer.periodic(interval, (timer) async {
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

  /// Captura un frame individual con verificación de permisos
  Future<String?> _captureFrame() async {
    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return null;
    }

    try {
      // Verificar rate limiting
      if (_lastCaptureTime != null) {
        final timeSinceLastCapture = DateTime.now().difference(_lastCaptureTime!);
        if (timeSinceLastCapture < AppConstants.minCaptureInterval) {
          return null; // Esperar más tiempo
        }
      }

      final image = await _controller!.takePicture();
      _lastCaptureTime = DateTime.now();
      _capturedFrames++;

      // Emitir el frame capturado
      _frameStreamController.add(image.path);
      
      return image.path;
    } catch (e) {
      _errorStreamController.add(CameraException(
        'Capture error',
        'Error al capturar frame: $e',
      ));
      return null;
    }
  }

  /// Captura una imagen manual con verificación de permisos
  Future<String?> captureImage() async {
    // Verificar permisos antes de capturar
    final permissionResult = await _permissionService.requestCameraPermission();
    if (!permissionResult.isGranted) {
      _permissionStreamController.add(permissionResult);
      return null;
    }

    return await _captureFrame();
  }

  /// Cambia la resolución de la cámara
  Future<void> changeResolution(ResolutionPreset resolution) async {
    if (!_isInitialized || _controller == null) {
      throw CameraException(
        'Not initialized',
        'La cámara no está inicializada',
      );
    }

    await _controller!.dispose();
    
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      camera,
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  /// Obtiene información de la cámara
  Map<String, dynamic> getCameraInfo() {
    if (!_isInitialized || _controller == null) {
      return {};
    }

    return {
      'isInitialized': _controller!.value.isInitialized,
      'isRecording': _controller!.value.isRecordingVideo,
      'resolution': _controller!.value.resolutionPreset.toString(),
      'flashMode': _controller!.value.flashMode.toString(),
      'exposureMode': _controller!.value.exposureMode.toString(),
      'focusMode': _controller!.value.focusMode.toString(),
      'capturedFrames': _capturedFrames,
      'isCapturing': _isCapturing,
    };
  }

  /// Obtiene el directorio temporal para guardar imágenes
  Future<Directory> getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Limpia archivos temporales
  Future<void> cleanupTemporaryFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && file.path.contains('bovino_')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignorar errores de limpieza
    }
  }

  /// Libera recursos
  Future<void> dispose() async {
    await stopFrameCapture();
    await _controller?.dispose();
    await _frameStreamController.close();
    await _errorStreamController.close();
    await _permissionStreamController.close();
    await cleanupTemporaryFiles();
    _isInitialized = false;
  }
} 