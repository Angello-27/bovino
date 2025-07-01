import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import '../../core/services/camera_service.dart';
import '../../core/errors/failures.dart';
import 'bovino_bloc.dart';
import 'frame_analysis_bloc.dart';

// Eventos para CameraBloc
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class StartCapture extends CameraEvent {}

class StopCapture extends CameraEvent {}

class PauseCapture extends CameraEvent {}

class ResumeCapture extends CameraEvent {}

class DisposeCamera extends CameraEvent {}

// Estados para CameraBloc
abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {}

class CameraCapturing extends CameraState {
  final String lastFramePath;

  const CameraCapturing(this.lastFramePath);

  @override
  List<Object?> get props => [lastFramePath];
}

class CameraError extends CameraState {
  final Failure failure;

  const CameraError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// Bloc para manejar la cámara
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraService cameraService;
  final BovinoBloc bovinoBloc;
  final Logger _logger = Logger();
  
  // Stream subscription
  StreamSubscription<String>? _frameSubscription;
  
  // Control de análisis
  bool _analysisEnabled = false;
  
  // Referencia al FrameAnalysisBloc
  FrameAnalysisBloc? _frameAnalysisBloc;

  CameraBloc({
    required this.cameraService,
    required this.bovinoBloc,
  }) : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartCapture>(_onStartCapture);
    on<StopCapture>(_onStopCapture);
    on<PauseCapture>(_onPauseCapture);
    on<ResumeCapture>(_onResumeCapture);
    on<DisposeCamera>(_onDisposeCamera);
  }

  /// Establecer referencia al FrameAnalysisBloc
  void setFrameAnalysisBloc(FrameAnalysisBloc frameAnalysisBloc) {
    _frameAnalysisBloc = frameAnalysisBloc;
    _logger.i('✅ FrameAnalysisBloc configurado en CameraBloc');
  }

  /// Activar envío de frames para análisis
  void enableAnalysis() {
    _analysisEnabled = true;
    _logger.i('✅ Análisis de frames activado');
  }

  /// Desactivar envío de frames para análisis
  void disableAnalysis() {
    _analysisEnabled = false;
    _logger.i('⏹️ Análisis de frames desactivado');
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(CameraLoading());
      _logger.i('Inicializando cámara...');

      await cameraService.initialize();
      
      // Configurar la suscripción al stream de frames
      _setupFrameStreamSubscription();
      
      emit(CameraReady());
      _logger.i('Cámara inicializada correctamente');
    } catch (e) {
      _logger.e('Error al inicializar cámara: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  /// Configurar la suscripción al stream de frames
  void _setupFrameStreamSubscription() {
    // Cancelar suscripción anterior si existe
    _frameSubscription?.cancel();
    
    // Crear nueva suscripción - SOLO para captura, NO para análisis automático
    _frameSubscription = cameraService.frameStream.listen(
      (framePath) {
        _logger.d('Frame capturado: $framePath');
        
        // Enviar frame al FrameAnalysisBloc SOLO si el análisis está activado
        if (_analysisEnabled) {
          _logger.i('📤 Enviando frame para análisis: $framePath');
          _frameAnalysisBloc?.add(ProcessFrameEvent(framePath: framePath));
        }
      },
      onError: (error) {
        _logger.e('Error en stream de frames: $error');
      },
    );
    
    _logger.i('✅ Suscripción al stream de frames configurada (análisis controlado)');
  }

  Future<void> _onStartCapture(
    StartCapture event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Iniciando captura de frames...');

      // Verificar que el stream esté configurado
      if (_frameSubscription == null) {
        _setupFrameStreamSubscription();
      }

      cameraService.startFrameCapture();
      emit(const CameraCapturing('')); // Estado inicial de captura

      _logger.i('Captura de frames iniciada');
    } catch (e) {
      _logger.e('Error al iniciar captura: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onStopCapture(
    StopCapture event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Deteniendo captura de frames...');

      cameraService.stopFrameCapture();
      emit(CameraReady());

      _logger.i('Captura de frames detenida');
    } catch (e) {
      _logger.e('Error al detener captura: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onPauseCapture(
    PauseCapture event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Pausando captura de frames...');

      cameraService.pauseFrameCapture();
      emit(CameraReady());

      _logger.i('Captura de frames pausada');
    } catch (e) {
      _logger.e('Error al pausar captura: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onResumeCapture(
    ResumeCapture event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Reanudando captura de frames...');

      cameraService.resumeFrameCapture();
      emit(const CameraCapturing('')); // Estado inicial de captura

      _logger.i('Captura de frames reanudada');
    } catch (e) {
      _logger.e('Error al reanudar captura: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onDisposeCamera(
    DisposeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Liberando recursos de cámara...');

      // Cancelar suscripción al stream
      await _frameSubscription?.cancel();
      _frameSubscription = null;

      await cameraService.dispose();
      emit(CameraInitial());

      _logger.i('Recursos de cámara liberados');
    } catch (e) {
      _logger.e('Error al liberar recursos: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  @override
  Future<void> close() {
    _frameSubscription?.cancel();
    return super.close();
  }
}
