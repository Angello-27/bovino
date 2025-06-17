import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/analysis_queue_service.dart';
import '../../../core/constants/app_constants.dart';
import '../molecules/loading_overlay.dart';
import '../molecules/permission_dialog.dart';
import '../atoms/custom_button.dart';
import '../atoms/info_card.dart';
import '../../../core/services/permission_service.dart';

class RealtimeCameraSection extends StatefulWidget {
  final Function(String) onImageCaptured;
  final Function(AnalysisResult) onAnalysisResult;
  final Function(AnalysisStatus) onStatusUpdate;

  const RealtimeCameraSection({
    super.key,
    required this.onImageCaptured,
    required this.onAnalysisResult,
    required this.onStatusUpdate,
  });

  @override
  State<RealtimeCameraSection> createState() => _RealtimeCameraSectionState();
}

class _RealtimeCameraSectionState extends State<RealtimeCameraSection> {
  late CameraService _cameraService;
  late AnalysisQueueService _analysisQueueService;
  
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _showControls = true;
  bool _permissionsGranted = false;
  Timer? _controlsTimer;
  
  // Configuración de captura
  Duration _captureInterval = AppConstants.defaultFrameInterval;
  int _maxFrames = AppConstants.defaultMaxFrames;
  int _capturedFrames = 0;
  
  // Estado de análisis
  int _queueLength = 0;
  int _activeAnalyses = 0;
  DateTime? _lastAnalysisTime;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Inicializar servicios
      _cameraService = CameraService();
      _analysisQueueService = AnalysisQueueService(
        // Aquí necesitarías inyectar el caso de uso
        // Por ahora usamos un placeholder
        null as dynamic,
      );

      // Configurar listeners
      _setupListeners();
      
      // Verificar permisos antes de inicializar
      await _checkPermissions();
    } catch (e) {
      _showError('Error al inicializar: $e');
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final permissionResult = await _cameraService.checkPermissions();
      
      if (permissionResult.isGranted) {
        setState(() {
          _permissionsGranted = true;
        });
        await _initializeCamera();
      } else {
        _showPermissionDialog();
      }
    } catch (e) {
      _showError('Error al verificar permisos: $e');
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initialize();
      
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      _showError('Error al inicializar cámara: $e');
    }
  }

  void _setupListeners() {
    // Escuchar frames capturados
    _cameraService.frameStream.listen((imagePath) {
      _capturedFrames++;
      widget.onImageCaptured(imagePath);
      
      // Agregar a la cola de análisis
      _analysisQueueService.enqueueAnalysis(imagePath);
    });

    // Escuchar errores de cámara
    _cameraService.errorStream.listen((error) {
      _showError('Error de cámara: ${error.description}');
    });

    // Escuchar resultados de permisos
    _cameraService.permissionStream.listen((permissionResult) {
      if (permissionResult.isGranted) {
        setState(() {
          _permissionsGranted = true;
        });
      } else {
        _showPermissionDialog();
      }
    });

    // Escuchar resultados de análisis
    _analysisQueueService.resultStream.listen((result) {
      widget.onAnalysisResult(result);
    });

    // Escuchar estado de análisis
    _analysisQueueService.statusStream.listen((status) {
      setState(() {
        _queueLength = status.queueLength;
        _activeAnalyses = status.activeAnalyses;
        _lastAnalysisTime = status.lastAnalysisTime;
      });
      widget.onStatusUpdate(status);
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        permissionService: PermissionService(),
        onPermissionsGranted: () {
          Navigator.pop(context);
          _initializeCamera();
        },
        onPermissionsDenied: () {
          Navigator.pop(context);
          _showError('Se requieren permisos para usar la cámara');
        },
      ),
    );
  }

  Future<void> _startAutoCapture() async {
    if (!_isInitialized || !_permissionsGranted) {
      await _checkPermissions();
      return;
    }

    try {
      await _cameraService.startFrameCapture(
        interval: _captureInterval,
        maxFrames: _maxFrames,
      );
      
      setState(() {
        _isCapturing = true;
        _capturedFrames = 0;
      });
      
      _hideControls();
    } catch (e) {
      _showError('Error al iniciar captura: $e');
    }
  }

  Future<void> _stopAutoCapture() async {
    await _cameraService.stopFrameCapture();
    
    setState(() {
      _isCapturing = false;
    });
    
    _showControls();
  }

  Future<void> _captureSingleFrame() async {
    if (!_isInitialized || !_permissionsGranted) {
      await _checkPermissions();
      return;
    }

    try {
      final imagePath = await _cameraService.captureImage();
      if (imagePath != null) {
        widget.onImageCaptured(imagePath);
        _analysisQueueService.enqueueAnalysis(imagePath);
      }
    } catch (e) {
      _showError('Error al capturar imagen: $e');
    }
  }

  void _hideControls() {
    setState(() {
      _showControls = false;
    });
    
    // Mostrar controles después de 3 segundos
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = true;
        });
      }
    });
  }

  void _showControls() {
    setState(() {
      _showControls = true;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return _buildPermissionRequiredWidget();
    }

    if (!_isInitialized) {
      return const LoadingOverlay(
        message: 'Inicializando cámara...',
      );
    }

    return Column(
      children: [
        // Vista previa de la cámara
        Expanded(
          child: Stack(
            children: [
              // Vista previa de la cámara
              CameraPreview(_cameraService.controller!),
              
              // Overlay de información
              if (_showControls) _buildInfoOverlay(),
              
              // Overlay de controles
              if (_showControls) _buildControlsOverlay(),
              
              // Indicador de captura
              if (_isCapturing) _buildCaptureIndicator(),
            ],
          ),
        ),
        
        // Panel de control inferior
        if (_showControls) _buildControlPanel(),
      ],
    );
  }

  Widget _buildPermissionRequiredWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Permisos de Cámara Requeridos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Para usar la cámara y analizar imágenes del ganado, necesitas conceder permisos de cámara y almacenamiento.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: _checkPermissions,
              text: 'Conceder Permisos',
              icon: Icons.camera_alt,
              backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isCapturing 
                ? 'Capturando frames automáticamente'
                : 'Cámara lista para capturar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Frames: $_capturedFrames | Cola: $_queueLength | Análisis: $_activeAnalyses',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón de captura manual
          FloatingActionButton(
            onPressed: _captureSingleFrame,
            backgroundColor: Colors.green,
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
          
          // Botón de captura automática
          FloatingActionButton(
            onPressed: _isCapturing ? _stopAutoCapture : _startAutoCapture,
            backgroundColor: _isCapturing ? Colors.red : Colors.blue,
            child: Icon(
              _isCapturing ? Icons.stop : Icons.play_arrow,
              color: Colors.white,
            ),
          ),
          
          // Botón de configuración
          FloatingActionButton(
            onPressed: _showSettings,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureIndicator() {
    return Positioned(
      top: 80,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CAPTURANDO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Configuración de captura
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Intervalo de captura'),
                    Slider(
                      value: _captureInterval.inSeconds.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '${_captureInterval.inSeconds}s',
                      onChanged: (value) {
                        setState(() {
                          _captureInterval = Duration(seconds: value.toInt());
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Máximo frames'),
                    Slider(
                      value: _maxFrames.toDouble(),
                      min: 5,
                      max: 20,
                      divisions: 15,
                      label: _maxFrames.toString(),
                      onChanged: (value) {
                        setState(() {
                          _maxFrames = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  onPressed: _clearQueue,
                  text: 'Limpiar Cola',
                  icon: Icons.clear_all,
                  backgroundColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  onPressed: _pauseResumeAnalysis,
                  text: _analysisQueueService.isProcessing ? 'Pausar' : 'Reanudar',
                  icon: _analysisQueueService.isProcessing ? Icons.pause : Icons.play_arrow,
                  backgroundColor: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configuración de Cámara'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Resolución Baja'),
              subtitle: const Text('640x480 - Más rápido'),
              onTap: () => _changeResolution(ResolutionPreset.low),
            ),
            ListTile(
              title: const Text('Resolución Media'),
              subtitle: const Text('1280x720 - Balanceado'),
              onTap: () => _changeResolution(ResolutionPreset.medium),
            ),
            ListTile(
              title: const Text('Resolución Alta'),
              subtitle: const Text('1920x1080 - Mejor calidad'),
              onTap: () => _changeResolution(ResolutionPreset.high),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeResolution(ResolutionPreset resolution) async {
    try {
      await _cameraService.changeResolution(resolution);
      Navigator.pop(context);
    } catch (e) {
      _showError('Error al cambiar resolución: $e');
    }
  }

  void _clearQueue() {
    _analysisQueueService.clearQueue();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cola de análisis limpiada'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _pauseResumeAnalysis() {
    if (_analysisQueueService.isProcessing) {
      _analysisQueueService.pauseProcessing();
    } else {
      _analysisQueueService.resumeProcessing();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _cameraService.dispose();
    _analysisQueueService.dispose();
    super.dispose();
  }
} 