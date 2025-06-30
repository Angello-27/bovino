import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Core
import '../../core/services/frame_analysis_service.dart';
// import '../../core/di/dependency_injection.dart';

/// Eventos del FrameAnalysisBloc
abstract class FrameAnalysisEvent extends Equatable {
  const FrameAnalysisEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para iniciar análisis de frames
class StartFrameAnalysisEvent extends FrameAnalysisEvent {
  const StartFrameAnalysisEvent();
}

/// Evento para detener análisis de frames
class StopFrameAnalysisEvent extends FrameAnalysisEvent {
  const StopFrameAnalysisEvent();
}

/// Evento para enviar frame al servidor
class SendFrameEvent extends FrameAnalysisEvent {
  final String frameId;
  final File imageFile;

  const SendFrameEvent({
    required this.frameId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [frameId, imageFile];
}

/// Evento para procesar frame desde CameraBloc
class ProcessFrameEvent extends FrameAnalysisEvent {
  final String framePath;

  const ProcessFrameEvent({required this.framePath});

  @override
  List<Object?> get props => [framePath];
}

/// Evento para verificar estado de frame
class CheckFrameStatusEvent extends FrameAnalysisEvent {
  final String frameId;

  const CheckFrameStatusEvent({required this.frameId});

  @override
  List<Object?> get props => [frameId];
}

/// Estados del FrameAnalysisBloc
abstract class FrameAnalysisState extends Equatable {
  const FrameAnalysisState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FrameAnalysisInitial extends FrameAnalysisState {}

/// Estado de procesamiento
class FrameAnalysisProcessing extends FrameAnalysisState {
  final int pendingFrames;
  final int processedFrames;
  final int successfulFrames;

  const FrameAnalysisProcessing({
    this.pendingFrames = 0,
    this.processedFrames = 0,
    this.successfulFrames = 0,
  });

  @override
  List<Object?> get props => [pendingFrames, processedFrames, successfulFrames];
}

/// Estado de éxito
class FrameAnalysisSuccess extends FrameAnalysisState {
  final Map<String, dynamic> result;

  const FrameAnalysisSuccess({required this.result});

  @override
  List<Object?> get props => [result];
}

/// Estado de error
class FrameAnalysisError extends FrameAnalysisState {
  final String message;

  const FrameAnalysisError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// BLoC para manejar el análisis de frames
class FrameAnalysisBloc extends Bloc<FrameAnalysisEvent, FrameAnalysisState> {
  late FrameAnalysisService _frameAnalysisService;
  final Logger _logger = Logger();
  
  Timer? _frameTimer;
  Timer? _statusTimer;
  final List<String> _pendingFrames = [];
  final Map<String, dynamic> _results = {};
  
  int _processedFrames = 0;
  int _successfulFrames = 0;

  FrameAnalysisBloc({FrameAnalysisService? frameAnalysisService}) 
      : super(FrameAnalysisInitial()) {
    _initializeFrameAnalysisService(frameAnalysisService);
    on<StartFrameAnalysisEvent>(_onStartFrameAnalysis);
    on<StopFrameAnalysisEvent>(_onStopFrameAnalysis);
    on<SendFrameEvent>(_onSendFrame);
    on<ProcessFrameEvent>(_onProcessFrame);
    on<CheckFrameStatusEvent>(_onCheckFrameStatus);
  }

  void _initializeFrameAnalysisService(FrameAnalysisService? frameAnalysisService) {
    try {
      if (frameAnalysisService != null) {
        _frameAnalysisService = frameAnalysisService;
      } else if (GetIt.instance.isRegistered<FrameAnalysisService>()) {
        _frameAnalysisService = GetIt.instance<FrameAnalysisService>();
      } else if (GetIt.instance.isRegistered<Dio>()) {
        final dio = GetIt.instance<Dio>();
        _frameAnalysisService = FrameAnalysisService(dio);
      } else {
        // Fallback: crear con Dio por defecto
        final dio = Dio();
        _frameAnalysisService = FrameAnalysisService(dio);
      }
      _logger.i('✅ FrameAnalysisService inicializado correctamente');
    } catch (e) {
      _logger.e('❌ Error al inicializar FrameAnalysisService: $e');
      // Fallback final
      final dio = Dio();
      _frameAnalysisService = FrameAnalysisService(dio);
    }
  }

  /// Maneja el evento de iniciar análisis de frames
  Future<void> _onStartFrameAnalysis(
    StartFrameAnalysisEvent event,
    Emitter<FrameAnalysisState> emit,
  ) async {
    try {
      _logger.i('🚀 Iniciando análisis de frames...');
      
      // Limpiar estado anterior
      _pendingFrames.clear();
      _results.clear();
      _processedFrames = 0;
      _successfulFrames = 0;
      
      // Solo cambiar el estado - NO enviar frames automáticamente
      emit(const FrameAnalysisProcessing());
      _logger.i('✅ Análisis de frames iniciado - Esperando frames del CameraBloc');
    } catch (e) {
      _logger.e('❌ Error al iniciar análisis de frames: $e');
      emit(FrameAnalysisError(message: 'Error al iniciar análisis: $e'));
    }
  }

  /// Maneja el evento de detener análisis de frames
  Future<void> _onStopFrameAnalysis(
    StopFrameAnalysisEvent event,
    Emitter<FrameAnalysisState> emit,
  ) async {
    try {
      _logger.i('⏹️ Deteniendo análisis de frames...');
      
      // Cancelar timers si existen
      _frameTimer?.cancel();
      _statusTimer?.cancel();
      
      // Limpiar frames pendientes
      _pendingFrames.clear();
      
      // Volver al estado inicial
      emit(FrameAnalysisInitial());
      _logger.i('✅ Análisis de frames detenido');
    } catch (e) {
      _logger.e('❌ Error al detener análisis de frames: $e');
      emit(FrameAnalysisError(message: 'Error al detener análisis: $e'));
    }
  }

  /// Maneja el evento de enviar frame
  Future<void> _onSendFrame(
    SendFrameEvent event,
    Emitter<FrameAnalysisState> emit,
  ) async {
    try {
      _logger.d('📤 Enviando frame: ${event.frameId}');
      
      final frameId = await _frameAnalysisService.submitFrameForAnalysis(
        event.imageFile,
        metadata: {'source': 'camera', 'timestamp': DateTime.now().toIso8601String()},
      );
      
      _pendingFrames.add(frameId);
      _logger.d('✅ Frame enviado exitosamente: $frameId');
    } catch (e) {
      _logger.e('❌ Error al enviar frame: $e');
    }
  }

  /// Maneja el evento de procesar frame
  Future<void> _onProcessFrame(
    ProcessFrameEvent event,
    Emitter<FrameAnalysisState> emit,
  ) async {
    try {
      _logger.i('📤 Procesando frame: ${event.framePath}');
      
      // Verificar que el archivo existe
      final file = File(event.framePath);
      if (!await file.exists()) {
        _logger.w('⚠️ Archivo no encontrado: ${event.framePath}');
        return;
      }
      
      // Intentar analizar el frame
      try {
        final result = await _frameAnalysisService.analyzeFrameSync(file);
        _logger.i('✅ Frame analizado exitosamente');
        
        // Emitir resultado exitoso
        emit(FrameAnalysisSuccess(result: result));
        
        _successfulFrames++;
      } catch (e) {
        _logger.w('⚠️ Error al analizar frame (servidor no disponible): $e');
        // NO emitir error - solo continuar capturando
        // La aplicación debe funcionar aunque el servidor no esté disponible
      }
      
      _processedFrames++;
      
    } catch (e) {
      _logger.e('❌ Error inesperado al procesar frame: $e');
      // NO emitir error - solo continuar capturando
    }
  }

  /// Maneja el evento de verificar estado de frame
  Future<void> _onCheckFrameStatus(
    CheckFrameStatusEvent event,
    Emitter<FrameAnalysisState> emit,
  ) async {
    try {
      _logger.d('🔍 Verificando estado de frame: ${event.frameId}');
      
      final result = await _frameAnalysisService.checkFrameStatus(event.frameId);
      
      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        // Frame procesado exitosamente
        _pendingFrames.remove(event.frameId);
        _processedFrames++;
        _successfulFrames++;
        
        final bovinoResult = result['result'] as Map<String, dynamic>;
        final resultData = {
          'raza': bovinoResult['raza'] ?? 'No detectado',
          'peso': bovinoResult['peso']?.toString() ?? '0',
          'confianza': bovinoResult['confianza']?.toString() ?? '0',
          'caracteristicas': (bovinoResult['caracteristicas'] as List<dynamic>?)?.join(', ') ?? '',
        };
        
        _results[event.frameId] = resultData;
        
        _logger.i('✅ Frame procesado: ${event.frameId}');
        
        // Emitir resultado
        emit(FrameAnalysisSuccess(result: resultData));
        
        // Actualizar estado de procesamiento
        emit(FrameAnalysisProcessing(
          pendingFrames: _pendingFrames.length,
          processedFrames: _processedFrames,
          successfulFrames: _successfulFrames,
        ));
      } else if (result != null && result['status'] == 'failed') {
        // Frame falló
        _pendingFrames.remove(event.frameId);
        _processedFrames++;
        
        _logger.e('❌ Frame falló: ${event.frameId} - ${result['error']}');
        
        // Actualizar estado de procesamiento
        emit(FrameAnalysisProcessing(
          pendingFrames: _pendingFrames.length,
          processedFrames: _processedFrames,
          successfulFrames: _successfulFrames,
        ));
      } else {
        _logger.d('⏳ Frame aún procesándose: ${event.frameId}');
      }
    } catch (e) {
      _logger.e('❌ Error al verificar estado de frame: $e');
    }
  }

  @override
  Future<void> close() {
    _logger.i('🔌 Cerrando FrameAnalysisBloc');
    _frameTimer?.cancel();
    _statusTimer?.cancel();
    return super.close();
  }
} 