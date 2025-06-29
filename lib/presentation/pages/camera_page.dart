import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/camera_service.dart' as camera_service;

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
  final Logger _logger = Logger();
  
  bool _permissionsGranted = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  void _initializeBlocs() {
    try {
      // Intentar obtener BLoCs desde GetIt
      if (GetIt.instance.isRegistered<CameraBloc>()) {
        _cameraBloc = GetIt.instance<CameraBloc>();
        _logger.i('✅ CameraBloc obtenido desde GetIt en CameraPage');
      } else {
        // Crear CameraBloc con CameraService
        final cameraService = GetIt.instance.isRegistered<camera_service.CameraService>()
            ? GetIt.instance<camera_service.CameraService>()
            : camera_service.CameraService();
        _cameraBloc = CameraBloc(cameraService: cameraService);
        _logger.w('⚠️ CameraBloc no registrado en GetIt, creando manualmente en CameraPage');
      }

      if (GetIt.instance.isRegistered<FrameAnalysisBloc>()) {
        _frameAnalysisBloc = GetIt.instance<FrameAnalysisBloc>();
        _logger.i('✅ FrameAnalysisBloc obtenido desde GetIt en CameraPage');
      } else {
        _frameAnalysisBloc = FrameAnalysisBloc();
        _logger.w('⚠️ FrameAnalysisBloc no registrado en GetIt, creando manualmente en CameraPage');
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
      _logger.i('🔐 Solicitando permisos de cámara y almacenamiento...');
      
      final cameraStatus = await Permission.camera.request();
      final storageStatus = await Permission.storage.request();
      
      final granted = cameraStatus.isGranted && storageStatus.isGranted;
      
      setState(() {
        _permissionsGranted = granted;
      });
      
      if (granted) {
        _logger.i('✅ Permisos concedidos');
        _initializeCamera();
      } else {
        _logger.w('❌ Permisos denegados');
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      _logger.e('❌ Error al solicitar permisos: $e');
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
      builder: (context) => AlertDialog(
        title: const Text('Permisos Requeridos'),
        content: const Text(
          'Esta aplicación necesita acceso a la cámara y almacenamiento para analizar ganado bovino. '
          'Por favor, concede los permisos en la configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home');
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Configuración'),
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
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const CustomText(
        text: 'Análisis Bovino',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          _stopAnalysis();
          context.go('/home');
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Vista de cámara
        Expanded(
          flex: 3,
          child: _buildCameraView(),
        ),
        
        // Panel de control
        Expanded(
          flex: 1,
          child: _buildControlPanel(),
        ),
        
        // Resultados
        Expanded(
          flex: 2,
          child: _buildResultsPanel(),
        ),
      ],
    );
  }

  Widget _buildCameraView() {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        if (state is CameraInitial) {
          return _buildCameraPlaceholder('Inicializando cámara...');
        } else if (state is CameraLoading) {
          return _buildCameraPlaceholder('Cargando cámara...');
        } else if (state is CameraError) {
          return _buildCameraPlaceholder('Error: ${state.failure.message}');
        } else if (state is CameraReady) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAnalyzing ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                color: Colors.black,
                child: const Center(
                  child: Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        } else {
          return _buildCameraPlaceholder('Cámara no disponible');
        }
      },
    );
  }

  Widget _buildCameraPlaceholder(String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            CustomText(
              text: message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _isAnalyzing ? _stopAnalysis : _startAnalysis,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAnalyzing ? Colors.red : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(_isAnalyzing ? 'Detener' : 'Iniciar'),
          ),
          BlocBuilder<FrameAnalysisBloc, FrameAnalysisState>(
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: state is FrameAnalysisProcessing ? Colors.orange : Colors.grey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: CustomText(
                  text: state is FrameAnalysisProcessing 
                      ? 'Procesando: ${state.pendingFrames}'
                      : 'En espera',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
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
          return _buildResultsPlaceholder('Inicia el análisis para ver resultados');
        } else if (state is FrameAnalysisProcessing) {
          return _buildResultsPlaceholder('Procesando frames...');
        } else if (state is FrameAnalysisSuccess) {
          return _buildResultsContent(state.result);
        } else if (state is FrameAnalysisError) {
          return _buildResultsPlaceholder('Error: ${state.message}');
        } else {
          return _buildResultsPlaceholder('Esperando resultados...');
        }
      },
    );
  }

  Widget _buildResultsPlaceholder(String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: CustomText(
          text: message,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsContent(dynamic result) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: 'Resultado del Análisis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          CustomText(
            text: 'Raza: ${result['raza'] ?? 'No detectada'}',
            style: const TextStyle(fontSize: 16),
          ),
          CustomText(
            text: 'Peso estimado: ${result['peso'] ?? 'No disponible'} kg',
            style: const TextStyle(fontSize: 16),
          ),
          CustomText(
            text: 'Confianza: ${result['confianza'] ?? '0'}%',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
