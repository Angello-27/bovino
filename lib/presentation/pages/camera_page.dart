import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:camera/camera.dart';
import '../../core/services/camera_service.dart' as camera_service;
import '../../core/services/permission_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_messages.dart';

// BLoCs
import '../blocs/camera_bloc.dart';
import '../blocs/frame_analysis_bloc.dart';
import '../blocs/bovino_bloc.dart';
import '../../domain/repositories/bovino_repository.dart';

// Atoms
import '../widgets/atoms/custom_text.dart';

/// Página de cámara para análisis de ganado bovino
/// Maneja permisos, captura de frames y comunicación con el servidor
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraBloc _cameraBloc;
  late FrameAnalysisBloc _frameAnalysisBloc;
  late PermissionService _permissionService;
  final Logger _logger = Logger();

  bool _permissionsGranted = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeServices();
    _initializeBlocs();
    _requestPermissions();
    
    // Escuchar cambios en el estado de la cámara
    _cameraBloc.stream.listen((state) {
      _logger.i('📷 Estado de cámara cambiado: $state');
      if (state is CameraReady) {
        _logger.i('✅ Cámara lista - Controller inicializado: ${_cameraBloc.cameraService.controller?.value.isInitialized}');
      } else if (state is CameraError) {
        _logger.e('❌ Error en cámara: ${state.failure.message}');
      }
    });
  }

  @override
  void dispose() {
    try {
      _logger.i('🧹 Liberando recursos de CameraPage...');
      
      // Detener análisis si está activo
      if (_isAnalyzing) {
        _stopAnalysis();
      }
      
      // Liberar recursos de cámara
      _cameraBloc.add(DisposeCamera());
      
      // Remover observer
      WidgetsBinding.instance.removeObserver(this);
      
      // Cerrar BLoCs
      _cameraBloc.close();
      _frameAnalysisBloc.close();
      
      _logger.i('✅ Recursos de CameraPage liberados correctamente');
    } catch (e) {
      _logger.e('❌ Error al liberar recursos de CameraPage: $e');
    } finally {
      super.dispose();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopAnalysis();
    }
  }

  void _initializeServices() {
    try {
      if (GetIt.instance.isRegistered<PermissionService>()) {
        _permissionService = GetIt.instance<PermissionService>();
        _logger.i('✅ PermissionService obtenido desde GetIt en CameraPage');
      } else {
        _permissionService = PermissionService();
        _logger.w(
          '⚠️ PermissionService no registrado en GetIt, creando manualmente en CameraPage',
        );
      }
    } catch (e) {
      _logger.e('❌ Error al obtener PermissionService en CameraPage: $e');
      _permissionService = PermissionService();
    }
  }

  void _initializeBlocs() {
    try {
      // Intentar obtener BLoCs desde GetIt
      if (GetIt.instance.isRegistered<CameraBloc>()) {
        _cameraBloc = GetIt.instance<CameraBloc>();
        _logger.i('✅ CameraBloc obtenido desde GetIt en CameraPage');
      } else {
        // Crear CameraBloc con CameraService
        final cameraService =
            GetIt.instance.isRegistered<camera_service.CameraService>()
                ? GetIt.instance<camera_service.CameraService>()
                : camera_service.CameraService();
        
        // Obtener BovinoBloc o crear uno nuevo
        final bovinoBloc = GetIt.instance.isRegistered<BovinoBloc>()
            ? GetIt.instance<BovinoBloc>()
            : BovinoBloc(repository: GetIt.instance<BovinoRepository>());
        
        _cameraBloc = CameraBloc(
          cameraService: cameraService,
          bovinoBloc: bovinoBloc,
        );
        _logger.w(
          '⚠️ CameraBloc no registrado en GetIt, creando manualmente en CameraPage',
        );
      }

      if (GetIt.instance.isRegistered<FrameAnalysisBloc>()) {
        _frameAnalysisBloc = GetIt.instance<FrameAnalysisBloc>();
        _logger.i('✅ FrameAnalysisBloc obtenido desde GetIt en CameraPage');
      } else {
        _frameAnalysisBloc = FrameAnalysisBloc();
        _logger.w(
          '⚠️ FrameAnalysisBloc no registrado en GetIt, creando manualmente en CameraPage',
        );
      }
    } catch (e) {
      _logger.e('❌ Error al obtener BLoCs en CameraPage: $e');
      // Fallback: crear con servicios por defecto
      final cameraService = camera_service.CameraService();
      final bovinoBloc = BovinoBloc(repository: GetIt.instance<BovinoRepository>());
      _cameraBloc = CameraBloc(
        cameraService: cameraService,
        bovinoBloc: bovinoBloc,
      );
      _frameAnalysisBloc = FrameAnalysisBloc();
    }
  }

  Future<void> _requestPermissions() async {
    try {
      _logger.i('🔐 Solicitando permisos usando PermissionService...');

      // Usar PermissionService para solicitar permisos de cámara
      final cameraResult = await _permissionService.requestCameraPermission();

      // Para Android 11+, también solicitar permisos adicionales
      final storageResult = await _permissionService.requestStoragePermission();

      final granted = cameraResult.isGranted && storageResult.isGranted;

      setState(() {
        _permissionsGranted = granted;
      });

      if (granted) {
        _logger.i(
          '✅ Permisos concedidos: ${cameraResult.message} - ${storageResult.message}',
        );
        _initializeCamera();
      } else {
        _logger.w(
          '❌ Permisos denegados: ${cameraResult.message} - ${storageResult.message}',
        );
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _logger.e('❌ Error al solicitar permisos: $e');
      setState(() {
        _permissionsGranted = false;
      });
    }
  }

  void _initializeCamera() {
    _logger.i('📷 Inicializando cámara...');
    _logger.i('🔍 Estado actual de CameraBloc: ${_cameraBloc.state}');
    _logger.i('🔍 CameraService inicializado: ${_cameraBloc.cameraService.isInitialized}');
    _logger.i('🔍 CameraController disponible: ${_cameraBloc.cameraService.controller != null}');
    _cameraBloc.add(InitializeCamera());
  }

  void _startAnalysis() {
    if (!_permissionsGranted) {
      _requestPermissions();
      return;
    }

    _logger.i('🚀 Iniciando análisis de frames...');
    setState(() {
      _isAnalyzing = true;
    });

    _frameAnalysisBloc.add(const StartFrameAnalysisEvent());
    _cameraBloc.add(StartCapture());
  }

  void _stopAnalysis() {
    try {
      _logger.i('⏹️ Deteniendo análisis de frames...');
      
      setState(() {
        _isAnalyzing = false;
      });

      // Detener análisis de frames
      _frameAnalysisBloc.add(const StopFrameAnalysisEvent());
      
      // Detener captura de cámara
      _cameraBloc.add(StopCapture());
      
      _logger.i('✅ Análisis detenido correctamente');
    } catch (e) {
      _logger.e('❌ Error al detener análisis: $e');
      // Asegurar que el estado se actualice incluso si hay error
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.lightSurface,
            title: const Text(
              'Permisos Requeridos',
              style: TextStyle(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              AppMessages.helpPermissions,
              style: TextStyle(color: AppColors.lightTextSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  AppMessages.cancel,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.contentTextLight,
                ),
                child: const Text(AppMessages.settings),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CameraBloc>.value(value: _cameraBloc),
        BlocProvider<FrameAnalysisBloc>.value(value: _frameAnalysisBloc),
      ],
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryDark,
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [_buildAppBar(), Expanded(child: _buildBody())],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const CustomText(
        text: AppMessages.intelligentAnalysis,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.contentTextLight,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.contentTextLight.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.contentTextLight),
          onPressed: () async {
            try {
              _logger.i('🔙 Navegando hacia atrás...');
              
              // Detener análisis si está activo
              if (_isAnalyzing) {
                _stopAnalysis();
                // Esperar un poco para que se detenga correctamente
                await Future.delayed(const Duration(milliseconds: 500));
              }
              
              // Navegar hacia atrás
              if (mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              _logger.e('❌ Error al navegar hacia atrás: $e');
              // Intentar navegar de todas formas
              if (mounted) {
                Navigator.of(context).pop();
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.contentTextLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.contentTextLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Vista de cámara
          Expanded(flex: 3, child: _buildCameraView()),

          // Panel de control
          Expanded(flex: 1, child: _buildControlPanel()),

          // Resultados
          Expanded(flex: 2, child: _buildResultsPanel()),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is CameraInitial) {
          return _buildCameraPlaceholder(
            '🔄 Inicializando cámara...',
            AppColors.info,
          );
        } else if (state is CameraLoading) {
          return _buildCameraPlaceholder(
            '⏳ Cargando cámara...',
            AppColors.warning,
          );
        } else if (state is CameraError) {
          return _buildCameraPlaceholder(
            '❌ Error: ${state.failure.message}',
            AppColors.error,
          );
        } else if (state is CameraReady) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _isAnalyzing
                        ? [
                          AppColors.success.withValues(alpha: 0.3),
                          AppColors.success.withValues(alpha: 0.1),
                        ]
                        : [
                          AppColors.contentTextLight.withValues(alpha: 0.2),
                          AppColors.contentTextLight.withValues(alpha: 0.1),
                        ],
              ),
              border: Border.all(
                color:
                    _isAnalyzing
                        ? AppColors.success
                        : AppColors.contentTextLight.withValues(alpha: 0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _isAnalyzing
                          ? AppColors.success.withValues(alpha: 0.5)
                          : Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                children: [
                  // Vista real de la cámara
                  SizedBox.expand(
                    child: _cameraBloc.cameraService.controller != null && 
                           _cameraBloc.cameraService.controller!.value.isInitialized
                        ? FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraBloc.cameraService.controller!.value.previewSize?.width ?? 640,
                              height: _cameraBloc.cameraService.controller!.value.previewSize?.height ?? 480,
                              child: CameraPreview(_cameraBloc.cameraService.controller!),
                            ),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.darkSurface,
                                  AppColors.darkCardBackground,
                                ],
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: AppColors.contentTextLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Cámara no inicializada',
                                  style: TextStyle(
                                    color: AppColors.contentTextLight,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Controller: ${_cameraBloc.cameraService.controller != null ? "Disponible" : "No disponible"}',
                                  style: TextStyle(
                                    color: AppColors.contentTextLight.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Inicializado: ${_cameraBloc.cameraService.isInitialized ? "Sí" : "No"}',
                                  style: TextStyle(
                                    color: AppColors.contentTextLight.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  // Overlay de análisis
                  if (_isAnalyzing)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              color: AppColors.contentTextLight,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              AppMessages.analyzingStatus,
                              style: TextStyle(
                                color: AppColors.contentTextLight,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        } else {
          return _buildCameraPlaceholder(
            '📷 Cámara no disponible',
            AppColors.lightGrey,
          );
        }
      },
    );
  }

  Widget _buildCameraPlaceholder(String message, Color color) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 80,
              color: AppColors.contentTextLight,
            ),
            const SizedBox(height: 20),
            CustomText(
              text: message,
              style: const TextStyle(
                color: AppColors.contentTextLight,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.contentTextLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.contentTextLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón principal de análisis
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? _stopAnalysis : _startAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAnalyzing ? AppColors.error : AppColors.success,
                foregroundColor: AppColors.contentTextLight,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(_isAnalyzing ? Icons.stop : Icons.play_arrow),
              label: Text(
                _isAnalyzing ? AppMessages.stopAnalysis : AppMessages.startAnalysis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Botón de debug para reinicializar cámara
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _logger.i('🔧 Reinicializando cámara desde debug...');
                _cameraBloc.add(DisposeCamera());
                Future.delayed(const Duration(milliseconds: 500), () {
                  _initializeCamera();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: BorderSide(color: AppColors.warning),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text(
                'Reinicializar Cámara',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    return BlocBuilder<FrameAnalysisBloc, FrameAnalysisState>(
      builder: (context, state) {
        if (state is FrameAnalysisInitial) {
          return _buildResultsPlaceholder(
            '🎯 Inicia el análisis para ver resultados',
            AppColors.info,
          );
        } else if (state is FrameAnalysisProcessing) {
          return _buildResultsPlaceholder(
            '⚡ Procesando frames...',
            AppColors.warning,
          );
        } else if (state is FrameAnalysisSuccess) {
          return _buildResultsContent(state.result);
        } else if (state is FrameAnalysisError) {
          return _buildResultsPlaceholder(
            '❌ Error: ${state.message}',
            AppColors.error,
          );
        } else {
          return _buildResultsPlaceholder(
            '⏳ Esperando resultados...',
            AppColors.lightGrey,
          );
        }
      },
    );
  }

  Widget _buildResultsPlaceholder(String message, Color color) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics,
              size: 60,
              color: AppColors.contentTextLight,
            ),
            const SizedBox(height: 16),
            CustomText(
              text: message,
              style: const TextStyle(
                color: AppColors.contentTextLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsContent(dynamic result) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppGradients.successGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.contentTextLight,
                size: 24,
              ),
              SizedBox(width: 8),
              CustomText(
                text: AppMessages.analysisResult,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.contentTextLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildResultItem(
            '🐄 ${AppMessages.breed}',
            result['raza'] ?? AppMessages.notDetected,
          ),
          const SizedBox(height: 12),
          _buildResultItem(
            '⚖️ ${AppMessages.estimatedWeight}',
            '${result['peso'] ?? AppMessages.notAvailable} ${AppMessages.kg}',
          ),
          const SizedBox(height: 12),
          _buildResultItem(
            '📊 ${AppMessages.confidence}',
            '${result['confianza'] ?? '0'}${AppMessages.percent}',
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.contentTextLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.contentTextLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: label,
            style: const TextStyle(
              color: AppColors.contentTextLight,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          CustomText(
            text: value,
            style: const TextStyle(
              color: AppColors.contentTextLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
