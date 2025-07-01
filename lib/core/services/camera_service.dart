import 'dart:async';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
// import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
// import '../constants/app_messages.dart';
// import '../error/error_handler.dart';
import 'frame_analysis_service.dart';

/// Estados de la cámara
enum CameraState {
  initial,
  loading,
  ready,
  capturing,
  error,
}

/// Servicio optimizado para captura de frames de cámara
/// 
/// Maneja la captura automática de frames y envío asíncrono
/// para análisis de ganado bovino
class CameraService {
  final Logger _logger = Logger();
  
  // Cámara
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  
  // Captura de frames
  Timer? _frameCaptureTimer;
  bool _isCapturing = false;
  bool _isCapturingFrame = false;
  int _capturedFramesCount = 0;
  
  // Streams
  final StreamController<String> _frameCapturedController = 
      StreamController<String>.broadcast();
  final StreamController<CameraState> _cameraStateController = 
      StreamController<CameraState>.broadcast();
  
  // Servicio de análisis (se inyectará después)
  // FrameAnalysisService? _frameAnalysisService;

  /// Stream de frames capturados
  Stream<String> get frameStream => _frameCapturedController.stream;
  
  /// Stream de estado de la cámara
  Stream<CameraState> get cameraStateStream => _cameraStateController.stream;
  
  /// Verificar si la cámara está inicializada
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  
  /// Verificar si está capturando frames
  bool get isCapturing => _isCapturing;
  
  /// Número de frames capturados
  int get capturedFramesCount => _capturedFramesCount;

  /// Inicializar la cámara
  Future<void> initialize() async {
    try {
      _logger.i('📷 Inicializando cámara...');
      
      // Obtener cámaras disponibles
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No se encontraron cámaras disponibles');
      }
      
      // Usar la cámara trasera por defecto
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );
      
      // Inicializar controlador
      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      // Inicializar cámara
      await _controller!.initialize();
      
      // Desactivar flash automático
      await _controller!.setFlashMode(FlashMode.off);
      
      _logger.i('✅ Cámara inicializada correctamente');
      _cameraStateController.add(CameraState.ready);
      
    } catch (e) {
      _logger.e('❌ Error al inicializar cámara: $e');
      _cameraStateController.add(CameraState.error);
      rethrow;
    }
  }

  /// Iniciar captura automática de frames
  Future<void> startFrameCapture() async {
    try {
      if (!isInitialized) {
        throw Exception('Cámara no inicializada');
      }
      
      if (_isCapturing) {
        _logger.w('⚠️ Ya está capturando frames');
        return;
      }
      
      // Verificar que el stream esté disponible
      if (_frameCapturedController.isClosed) {
        throw Exception('Stream de frames no disponible');
      }
      
      _logger.i('🎬 Iniciando captura automática de frames...');
      
      _isCapturing = true;
      _capturedFramesCount = 0;
      
      // Iniciar timer para captura periódica
      _frameCaptureTimer = Timer.periodic(
        AppConstants.frameCaptureInterval,
        (timer) => _captureFrame(),
      );
      
      _cameraStateController.add(CameraState.capturing);
      _logger.i('✅ Captura de frames iniciada');
      
    } catch (e) {
      _logger.e('❌ Error al iniciar captura: $e');
      _isCapturing = false;
      rethrow;
    }
  }

  /// Detener captura de frames
  void stopFrameCapture() {
    _logger.i('🛑 Deteniendo captura de frames...');
    
    _frameCaptureTimer?.cancel();
    _frameCaptureTimer = null;
    _isCapturing = false;
    
    _cameraStateController.add(CameraState.ready);
    _logger.i('✅ Captura de frames detenida');
  }

  /// Pausar captura de frames (mantiene el stream activo)
  void pauseFrameCapture() {
    _logger.i('⏸️ Pausando captura de frames...');
    
    _frameCaptureTimer?.cancel();
    _frameCaptureTimer = null;
    _isCapturing = false;
    
    _cameraStateController.add(CameraState.ready);
    _logger.i('✅ Captura de frames pausada');
  }

  /// Reanudar captura de frames
  void resumeFrameCapture() {
    _logger.i('▶️ Reanudando captura de frames...');
    
    if (_isCapturing) {
      _logger.w('⚠️ Ya está capturando frames');
      return;
    }
    
    // Verificar que el stream esté disponible
    if (_frameCapturedController.isClosed) {
      _logger.e('❌ Stream de frames no disponible');
      return;
    }
    
    _isCapturing = true;
    
    // Reanudar timer para captura periódica
    _frameCaptureTimer = Timer.periodic(
      AppConstants.frameCaptureInterval,
      (timer) => _captureFrame(),
    );
    
    _cameraStateController.add(CameraState.capturing);
    _logger.i('✅ Captura de frames reanudada');
  }

  /// Capturar un frame individual
  Future<String?> captureFrame() async {
    try {
      if (!isInitialized) {
        throw Exception('Cámara no inicializada');
      }
      
      return await _captureFrame();
      
    } catch (e) {
      _logger.e('❌ Error al capturar frame: $e');
      return null;
    }
  }

  /// Método interno para capturar frame
  Future<String?> _captureFrame() async {
    try {
      if (_controller == null || !_controller!.value.isInitialized) {
        return null;
      }
      
      // 🔒 Protección contra capturas simultáneas
      if (_isCapturingFrame) {
        _logger.w('⚠️ Captura en progreso, saltando frame');
        return null;
      }
      
      _isCapturingFrame = true;
      
      // Capturar imagen
      final image = await _controller!.takePicture();
      
      // Comprimir imagen si está habilitado
      String processedImagePath = image.path;
      if (AppConstants.enableFrameCompression) {
        processedImagePath = await _compressImage(image.path);
      }
      
      _capturedFramesCount++;
      
      _logger.d('📸 Frame capturado: $processedImagePath ($_capturedFramesCount)');
      
      // Verificar si el stream está cerrado antes de emitir
      if (!_frameCapturedController.isClosed) {
        _frameCapturedController.add(processedImagePath);
      } else {
        _logger.w('⚠️ Stream de frames cerrado, no se puede emitir frame');
      }
      
      // Enviar para análisis asíncrono si el servicio está disponible
      // if (_frameAnalysisService != null) {
      //   _sendFrameForAnalysis(processedImagePath);
      // }
      
      return processedImagePath;
      
    } catch (e) {
      _logger.e('❌ Error en captura de frame: $e');
      return null;
    } finally {
      // 🔓 Liberar el lock de captura
      _isCapturingFrame = false;
    }
  }

  /// Comprimir imagen
  Future<String> _compressImage(String imagePath) async {
    try {
      // En una implementación real, aquí comprimirías la imagen
      // Por ahora, retornamos la ruta original
      return imagePath;
    } catch (e) {
      _logger.e('❌ Error al comprimir imagen: $e');
      return imagePath;
    }
  }

  /// Configurar el servicio de análisis de frames
  void setFrameAnalysisService(FrameAnalysisService service) {
    // _frameAnalysisService = service;
    _logger.i('🔗 FrameAnalysisService configurado');
  }

  /// Obtener controlador de cámara
  CameraController? get controller => _controller;

  /// Obtener cámaras disponibles
  List<CameraDescription>? get cameras => _cameras;

  /// Obtener estadísticas de captura
  Map<String, dynamic> getStats() {
    return {
      'isInitialized': isInitialized,
      'isCapturing': isCapturing,
      'capturedFramesCount': capturedFramesCount,
      'cameraCount': _cameras?.length ?? 0,
      'currentCamera': _controller?.description.name,
    };
  }

  /// Liberar recursos
  Future<void> dispose() async {
    _logger.i('🧹 Liberando recursos de cámara...');
    
    stopFrameCapture();
    
    await _controller?.dispose();
    _controller = null;
    
    await _frameCapturedController.close();
    await _cameraStateController.close();
    
    _logger.i('✅ Recursos de cámara liberados');
  }
}
