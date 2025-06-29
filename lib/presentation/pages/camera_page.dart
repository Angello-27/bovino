import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import '../../core/services/camera_service.dart' as camera_service;
import '../../core/services/permission_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_messages.dart';

// BLoCs
import '../blocs/camera_bloc.dart';
import '../blocs/frame_analysis_bloc.dart';

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraBloc.close();
    _frameAnalysisBloc.close();
    super.dispose();
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
        _cameraBloc = CameraBloc(cameraService: cameraService);
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
      _cameraBloc = CameraBloc(cameraService: cameraService);
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
    _logger.i('⏹️ Deteniendo análisis de frames...');
    setState(() {
      _isAnalyzing = false;
    });

    _frameAnalysisBloc.add(const StopFrameAnalysisEvent());
    _cameraBloc.add(StopCapture());
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
          onPressed: () {
            _stopAnalysis();
            Navigator.of(context).pop();
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
              child: Container(
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
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.camera_alt,
                        size: 80,
                        color: AppColors.contentTextLight,
                      ),
                    ),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.contentTextLight.withValues(alpha: 0.2),
            AppColors.contentTextLight.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: AppColors.contentTextLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón principal
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    _isAnalyzing
                        ? [
                          AppColors.error,
                          AppColors.error.withValues(alpha: 0.8),
                        ]
                        : [
                          AppColors.success,
                          AppColors.success.withValues(alpha: 0.8),
                        ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isAnalyzing ? AppColors.error : AppColors.success)
                      .withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isAnalyzing ? _stopAnalysis : _startAnalysis,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAnalyzing ? Icons.stop : Icons.play_arrow,
                    color: AppColors.contentTextLight,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isAnalyzing
                        ? AppMessages.stopAnalysis
                        : AppMessages.startAnalysis,
                    style: const TextStyle(
                      color: AppColors.contentTextLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Estado del análisis
          BlocBuilder<FrameAnalysisBloc, FrameAnalysisState>(
            builder: (context, state) {
              Color statusColor = AppColors.lightGrey;
              String statusText = AppMessages.waiting;
              IconData statusIcon = Icons.pause;

              if (state is FrameAnalysisProcessing) {
                statusColor = AppColors.warning;
                statusText =
                    '${AppMessages.processing}: ${state.pendingFrames}';
                statusIcon = Icons.sync;
              } else if (state is FrameAnalysisSuccess) {
                statusColor = AppColors.success;
                statusText = AppMessages.completed;
                statusIcon = Icons.check_circle;
              } else if (state is FrameAnalysisError) {
                statusColor = AppColors.error;
                statusText = AppMessages.error;
                statusIcon = Icons.error;
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      statusColor.withValues(alpha: 0.3),
                      statusColor.withValues(alpha: 0.1),
                    ],
                  ),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: AppColors.contentTextLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    CustomText(
                      text: statusText,
                      style: const TextStyle(
                        color: AppColors.contentTextLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
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
