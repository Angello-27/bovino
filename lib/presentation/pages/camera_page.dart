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
  Map<String, dynamic>? _lastSuccessfulResult;

  @override
  void initState() {
    super.initState();
    _logger.i('📱 Inicializando CameraPage...');
    
    // Configurar listener del ciclo de vida de la app
    WidgetsBinding.instance.addObserver(this);
    
    _initializeServices();
    _initializeBlocs();
    
    // Configurar UN SOLO listener del CameraBloc para evitar duplicados
    _cameraBloc.stream.listen((state) {
      _logger.i('📷 Estado de cámara cambiado: $state');
      if (state is CameraReady) {
        _logger.i('✅ Cámara lista - Controller inicializado: ${_cameraBloc.cameraService.controller?.value.isInitialized}');
      } else if (state is CameraError) {
        _logger.e('❌ Error en cámara: ${state.failure.message}');
      }
    });
    
    _requestPermissions();
  }

  @override
  void dispose() {
    try {
      _logger.i('🧹 Liberando recursos de CameraPage...');
      
      // Detener análisis si está activo
      if (_isAnalyzing) {
        _stopAnalysis();
      }
      
      // Liberar recursos de cámara (pero NO cerrar el BLoC)
      _cameraBloc.add(DisposeCamera());
      
      // Remover observer
      WidgetsBinding.instance.removeObserver(this);
      
      // NO cerrar los BLoCs aquí - pueden ser reutilizados
      // Los BLoCs se cierran automáticamente cuando la app se cierra
      // o cuando se destruye el widget padre
      
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
      _logger.i('📱 App pausada - limpiando estado del análisis...');
      _stopAnalysis();
      // Limpiar completamente el estado cuando se sale al home
      _frameAnalysisBloc.add(ClearFrameAnalysisStateEvent());
      // Limpiar también el resultado local
      _lastSuccessfulResult = null;
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
      
      // Configurar referencia del FrameAnalysisBloc en CameraBloc
      _cameraBloc.setFrameAnalysisBloc(_frameAnalysisBloc);
      
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
      
      // Configurar referencia
      _cameraBloc.setFrameAnalysisBloc(_frameAnalysisBloc);
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
    
    // Inicializar cámara
    _cameraBloc.add(InitializeCamera());
    
    // Después de un breve delay, iniciar captura de frames (sin análisis)
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted && _permissionsGranted) {
        _logger.i('🎬 Iniciando captura de frames (sin análisis)...');
        _cameraBloc.add(StartCapture());
        
        // Activar análisis automáticamente después de 2 segundos (para pruebas)
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _permissionsGranted) {
            _logger.i('🚀 Activando análisis automáticamente para pruebas...');
            _startAnalysis();
          }
        });
      }
    });
  }

  void _startAnalysis() {
    if (!_permissionsGranted) {
      _requestPermissions();
      return;
    }

    _logger.i('🚀 Iniciando análisis de frames...');
    setState(() {
      _isAnalyzing = true;
      // Limpiar resultado anterior al iniciar nuevo análisis
      _lastSuccessfulResult = null;
    });

    // Activar envío de frames para análisis en CameraBloc
    _cameraBloc.enableAnalysis();
    
    // Iniciar el análisis de frames
    _frameAnalysisBloc.add(const StartFrameAnalysisEvent());
    
    _logger.i('✅ Análisis iniciado - Cámara continúa funcionando');
  }

  void _stopAnalysis() {
    try {
      _logger.i('⏹️ Deteniendo análisis de frames...');
      
      setState(() {
        _isAnalyzing = false;
      });

      // Desactivar envío de frames para análisis en CameraBloc
      _cameraBloc.disableAnalysis();
      
      // Detener análisis de frames
      _frameAnalysisBloc.add(const StopFrameAnalysisEvent());
      
      _logger.i('✅ Análisis detenido - Cámara continúa funcionando');
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
    return Column(
      children: [
        // Cuadro de cámara más alto (60%) con botón integrado
        Expanded(
          flex: 6,
          child: _buildCameraSection(),
        ),
        // Panel de resultados más pequeño (40%) con márgenes
        Expanded(
          flex: 4,
          child: _buildResultsSection(),
        ),
      ],
    );
  }

  Widget _buildCameraSection() {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        _logger.d('🔍 Renderizando cámara - Estado: $state');
        _logger.d('🔍 Controller disponible: ${_cameraBloc.cameraService.controller != null}');
        _logger.d('🔍 Controller inicializado: ${_cameraBloc.cameraService.controller?.value.isInitialized}');
        _logger.d('🔍 CameraService inicializado: ${_cameraBloc.cameraService.isInitialized}');
        
        if (state is CameraInitial) {
          return Stack(
            children: [
              _buildCameraPlaceholder(
                '🔄 Inicializando cámara...',
                AppColors.info,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildControlButton(),
              ),
            ],
          );
        } else if (state is CameraLoading) {
          return Stack(
            children: [
              _buildCameraPlaceholder(
                '⏳ Cargando cámara...',
                AppColors.warning,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildControlButton(),
              ),
            ],
          );
        } else if (state is CameraError) {
          return Stack(
            children: [
              _buildCameraPlaceholder(
                '❌ Error: ${state.failure.message}',
                AppColors.error,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildControlButton(),
              ),
            ],
          );
        } else if (state is CameraReady) {
          _logger.i('✅ Renderizando CameraReady - Mostrando vista de cámara');
          return Stack(
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
                    : _buildCameraNotInitialized(),
              ),
              // Overlay de análisis
              if (_isAnalyzing)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildAnalysisOverlay(),
                ),
              // Botón de control en la parte inferior
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildControlButton(),
              ),
            ],
          );
        } else if (state is CameraCapturing) {
          _logger.i('✅ Renderizando CameraCapturing - Mostrando vista de cámara');
          return Stack(
            children: [
              // Vista real de la cámara (mismo que CameraReady)
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
                    : _buildCameraNotInitialized(),
              ),
              // Overlay de análisis
              if (_isAnalyzing)
                Positioned(
                  top: 16,
                  right: 16,
                  child: _buildAnalysisOverlay(),
                ),
              // Botón de control en la parte inferior
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildControlButton(),
              ),
            ],
          );
        } else {
          _logger.w('⚠️ Estado desconocido: $state - Mostrando placeholder');
          return Stack(
            children: [
              _buildCameraPlaceholder(
                '📷 Cámara no disponible',
                AppColors.lightGrey,
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _buildControlButton(),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildCameraPlaceholder(String message, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
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

  Widget _buildCameraNotInitialized() {
    return Container(
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
          const Text(
            'Cámara no inicializada',
            style: TextStyle(
              color: AppColors.contentTextLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
    );
  }

  Widget _buildAnalysisOverlay() {
    return Container(
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
    );
  }

  Widget _buildResultsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: BlocBuilder<FrameAnalysisBloc, FrameAnalysisState>(
        builder: (context, state) {
          // Guardar el resultado exitoso cuando se recibe
          if (state is FrameAnalysisSuccess) {
            _lastSuccessfulResult = state.result;
          }
          
          // Si tenemos un resultado exitoso, mostrarlo (incluso si el estado actual es Processing)
          if (_lastSuccessfulResult != null) {
            return _buildResultsContent(_lastSuccessfulResult!);
          }
          
          // Si no hay resultado exitoso, mostrar el estado actual
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
      ),
    );
  }

  Widget _buildResultsPlaceholder(String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.1)],
        ),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics,
              size: 48,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.success, Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                style:  TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.contentTextLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.contentTextLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.contentTextLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: CustomText(
              text: label,
              style: const TextStyle(
                color: AppColors.contentTextLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: CustomText(
              text: value,
              style: const TextStyle(
                color: AppColors.contentTextLight,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isAnalyzing ? _stopAnalysis : _startAnalysis,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isAnalyzing ? AppColors.error : AppColors.success,
          foregroundColor: AppColors.contentTextLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(_isAnalyzing ? Icons.stop : Icons.play_arrow, size: 24),
        label: Text(
          _isAnalyzing ? AppMessages.stopAnalysis : AppMessages.startAnalysis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
