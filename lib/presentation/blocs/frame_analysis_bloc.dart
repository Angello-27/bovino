import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:io';
import 'package:get_it/get_it.dart';

// Core
import '../../core/services/frame_analysis_service.dart';
import 'bovino_bloc.dart';

// Data
import '../../data/datasources/remote/tensorflow_server_datasource.dart';
import '../../domain/repositories/bovino_repository.dart';

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

/// Evento interno para actualizar estado de procesamiento
class _UpdateProcessingStateEvent extends FrameAnalysisEvent {}

/// Evento interno para emitir resultado
class _EmitResultEvent extends FrameAnalysisEvent {
  final Map<String, dynamic> result;
  const _EmitResultEvent(this.result);
  
  @override
  List<Object?> get props => [result];
}

/// Evento para limpiar completamente el estado (cuando se sale al home)
class ClearFrameAnalysisStateEvent extends FrameAnalysisEvent {}

/// BLoC para manejar el análisis de frames usando BovinoBloc
class FrameAnalysisBloc extends Bloc<FrameAnalysisEvent, FrameAnalysisState> {
  late FrameAnalysisService _frameAnalysisService;
  late BovinoBloc _bovinoBloc;
  final Logger _logger = Logger();
  
  Timer? _frameTimer;
  Timer? _statusTimer;
  StreamSubscription? _bovinoBlocSubscription;
  final List<String> _pendingFrames = [];
  final Map<String, dynamic> _results = {};
  
  int _processedFrames = 0;
  int _successfulFrames = 0;

  FrameAnalysisBloc({FrameAnalysisService? frameAnalysisService, BovinoBloc? bovinoBloc}) 
      : super(FrameAnalysisInitial()) {
    _initializeServices(frameAnalysisService, bovinoBloc);
    on<StartFrameAnalysisEvent>(_onStartFrameAnalysis);
    on<StopFrameAnalysisEvent>(_onStopFrameAnalysis);
    on<SendFrameEvent>(_onSendFrame);
    on<ProcessFrameEvent>(_onProcessFrame);
    on<CheckFrameStatusEvent>(_onCheckFrameStatus);
    on<_UpdateProcessingStateEvent>(_onUpdateProcessingState);
    on<_EmitResultEvent>(_onEmitResult);
    on<ClearFrameAnalysisStateEvent>(_onClearFrameAnalysisState);
    
    // Inicializar listener del BovinoBloc
    _listenToBovinoBloc();
  }

  void _initializeServices(FrameAnalysisService? frameAnalysisService, BovinoBloc? bovinoBloc) {
    try {
      // Inicializar FrameAnalysisService
      if (frameAnalysisService != null) {
        _frameAnalysisService = frameAnalysisService;
      } else if (GetIt.instance.isRegistered<FrameAnalysisService>()) {
        _frameAnalysisService = GetIt.instance<FrameAnalysisService>();
      } else {
        // Fallback: crear con datasource por defecto
        final datasource = GetIt.instance.isRegistered<TensorFlowServerDataSource>()
            ? GetIt.instance<TensorFlowServerDataSource>()
            : throw Exception('TensorFlowServerDataSource no registrado');
        _frameAnalysisService = FrameAnalysisService(datasource);
      }
      _logger.i('✅ FrameAnalysisService inicializado correctamente');

      // Inicializar BovinoBloc
      if (bovinoBloc != null) {
        _bovinoBloc = bovinoBloc;
      } else if (GetIt.instance.isRegistered<BovinoBloc>()) {
        _bovinoBloc = GetIt.instance<BovinoBloc>();
      } else {
        // Fallback: crear BovinoBloc manualmente
        final repository = GetIt.instance.isRegistered<BovinoRepository>()
            ? GetIt.instance<BovinoRepository>()
            : throw Exception('BovinoRepository no registrado');
        _bovinoBloc = BovinoBloc(repository: repository);
      }
      _logger.i('✅ BovinoBloc inicializado correctamente');
    } catch (e) {
      _logger.e('❌ Error al inicializar servicios: $e');
      rethrow;
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
      
      // Limpiar estado del BovinoBloc
      _bovinoBloc.add(ClearBovinoState());
      
      // NO volver al estado inicial - mantener el último resultado exitoso
      // Si hay un resultado exitoso, mantenerlo visible
      if (_results.isNotEmpty) {
        final lastResult = _results.values.last;
        _logger.i('✅ Manteniendo resultado visible: ${lastResult['raza']} - ${lastResult['confianza']}');
        emit(FrameAnalysisSuccess(result: lastResult));
      } else {
        // Solo si no hay resultados, volver al estado inicial
        emit(FrameAnalysisInitial());
      }
      
      _logger.i('✅ Análisis de frames detenido - Resultado mantenido');
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
      
      // Usar BovinoBloc para enviar el frame
      _bovinoBloc.add(SubmitFrameForAnalysis(event.imageFile.path));
      
      _logger.d('✅ Frame enviado exitosamente: ${event.frameId}');
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
      
      // Usar BovinoBloc para enviar frame para análisis asíncrono
      try {
        _bovinoBloc.add(SubmitFrameForAnalysis(event.framePath));
        _logger.i('✅ Frame enviado para análisis asíncrono: ${event.framePath}');
        
        // Iniciar verificación de estado si no está activa
        if (_statusTimer == null || !_statusTimer!.isActive) {
          _startStatusPolling();
        }
        
      } catch (e) {
        _logger.w('⚠️ Error al enviar frame (servidor no disponible): $e');
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
      
      // Usar el servicio directamente para verificar el estado
      final result = await _frameAnalysisService.checkFrameStatus(event.frameId);
      
      if (result != null && result['status'] == 'completed' && result['result'] != null) {
        // Frame procesado exitosamente
        _pendingFrames.remove(event.frameId);
        _processedFrames++;
        _successfulFrames++;
        
        final bovinoResult = result['result'] as Map<String, dynamic>;
        final resultData = {
          'raza': bovinoResult['raza'] ?? 'No detectado',
          'peso': bovinoResult['peso_estimado']?.toString() ?? '0',
          'confianza': bovinoResult['confianza']?.toString() ?? '0',
          'caracteristicas': (bovinoResult['caracteristicas'] as List<dynamic>?)?.join(', ') ?? '',
        };
        
        _results[event.frameId] = resultData;
        
        _logger.i('✅ Frame procesado: ${event.frameId} - Raza: ${resultData['raza']} - Confianza: ${resultData['confianza']}');
        
        // Verificar si debemos mostrar este resultado
        _shouldShowResult(resultData);
        
        // NO emitir FrameAnalysisProcessing después del primer resultado exitoso
        // Solo mantener el estado actual (FrameAnalysisSuccess) si ya tenemos un resultado
        if (_results.length == 1) {
          // Primer resultado - ya se emitió FrameAnalysisSuccess en _shouldShowResult
          _logger.d('🎯 Primer resultado obtenido - manteniendo estado de éxito');
        } else {
          // Resultados adicionales - el estado ya se actualizó en _shouldShowResult
          _logger.d('🔄 Resultado adicional - estado actualizado en _shouldShowResult');
        }
      } else if (result != null && result['status'] == 'failed') {
        // Frame falló
        _pendingFrames.remove(event.frameId);
        _processedFrames++;
        
        _logger.e('❌ Frame falló: ${event.frameId} - ${result['error']}');
        
        // NO emitir FrameAnalysisProcessing si ya tenemos un resultado exitoso
        if (_results.isNotEmpty) {
          _logger.d('⚠️ Frame falló pero manteniendo resultado exitoso existente');
        } else {
          // Solo emitir procesamiento si no hay resultados exitosos
          emit(FrameAnalysisProcessing(
            pendingFrames: _pendingFrames.length,
            processedFrames: _processedFrames,
            successfulFrames: _successfulFrames,
          ));
        }
      } else if (result != null && result['status'] == 'pending') {
        _logger.d('⏳ Frame aún pendiente: ${event.frameId}');
      } else if (result != null && result['status'] == 'processing') {
        _logger.d('🔄 Frame procesándose: ${event.frameId}');
      } else {
        _logger.w('⚠️ Estado desconocido para frame: ${event.frameId} - $result');
      }
    } catch (e) {
      _logger.e('❌ Error al verificar estado de frame: $e');
      // NO remover de la lista si hay error de red
    }
  }

  /// Verificar si debemos mostrar este resultado con restricciones de precisión
  void _shouldShowResult(Map<String, dynamic> newResult) {
    // Obtener el resultado actual si existe
    final currentResult = _results.values.isNotEmpty ? _results.values.first : null;
    
    if (currentResult == null) {
      // Primer resultado - verificar que tenga al menos 0.6% de precisión
      final newConfidence = double.tryParse(newResult['confianza'] ?? '0') ?? 0.0;
      if (newConfidence >= 0.6) {
        _logger.i('🎯 Primer resultado válido - mostrando: ${newResult['raza']} (${newResult['confianza']})');
        add(_EmitResultEvent(newResult));
      } else {
        _logger.w('⚠️ Primer resultado rechazado - precisión muy baja: ${newResult['raza']} (${newResult['confianza']}) < 0.6');
      }
      return;
    }
    
    final currentConfidence = double.tryParse(currentResult['confianza'] ?? '0') ?? 0.0;
    final newConfidence = double.tryParse(newResult['confianza'] ?? '0') ?? 0.0;
    final currentBreed = currentResult['raza'] ?? '';
    final newBreed = newResult['raza'] ?? '';
    
    // Si la precisión actual es muy alta (≥0.95), no cambiar
    if (currentConfidence >= 0.95) {
      _logger.d('🏆 Resultado final alcanzado - manteniendo: ${currentResult['raza']} (${currentResult['confianza']})');
      return;
    }
    
    // Verificar si es la misma raza
    final isSameBreed = newBreed == currentBreed;
    
    // Lógica de reemplazo:
    // 1. Si es la misma raza: solo cambiar si la nueva precisión es mayor
    // 2. Si es diferente raza: cambiar solo si la nueva precisión es ≥0.6
    // 3. Si la precisión actual es ≤0.5: cambiar si la nueva es mayor (sin importar raza)
    
    bool shouldReplace = false;
    String reason = '';
    
    if (isSameBreed) {
      // Misma raza: solo cambiar si la nueva precisión es mayor
      if (newConfidence > currentConfidence) {
        shouldReplace = true;
        reason = 'misma raza con mejor precisión';
      }
    } else {
      // Diferente raza: verificar restricciones
      if (currentConfidence <= 0.5) {
        // Si la precisión actual es baja (≤0.5), cambiar si la nueva es mayor
        if (newConfidence > currentConfidence) {
          shouldReplace = true;
          reason = 'diferente raza con mejor precisión (precisión actual baja)';
        }
      } else {
        // Si la precisión actual es >0.5, la nueva debe ser ≥0.6 para cambiar
        if (newConfidence >= 0.6) {
          shouldReplace = true;
          reason = 'diferente raza con precisión ≥0.6';
        }
      }
    }
    
    if (shouldReplace) {
      _logger.i('🔄 Reemplazando resultado: ${currentResult['raza']} (${currentResult['confianza']}) → ${newResult['raza']} (${newResult['confianza']}) - Razón: $reason');
      add(_EmitResultEvent(newResult));
    } else {
      _logger.d('⏭️ Manteniendo resultado actual: ${currentResult['raza']} (${currentResult['confianza']}) - Nueva: ${newResult['raza']} (${newResult['confianza']}) - No cumple criterios');
    }
  }

  /// Iniciar polling de estado de frames
  void _startStatusPolling() {
    _logger.i('🔄 Iniciando polling de estado de frames...');
    
    _statusTimer?.cancel();
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_pendingFrames.isEmpty) {
        _logger.d('📭 No hay frames pendientes, deteniendo polling');
        timer.cancel();
        return;
      }
      
      _logger.d('🔍 Polling: verificando ${_pendingFrames.length} frames pendientes');
      
      // Verificar estado de cada frame pendiente
      for (final frameId in List.from(_pendingFrames)) {
        add(CheckFrameStatusEvent(frameId: frameId));
      }
    });
    
    _logger.i('✅ Polling iniciado - verificando cada 2 segundos');
  }

  /// Escuchar el estado del BovinoBloc para capturar frame_ids
  void _listenToBovinoBloc() {
    _logger.i('🎧 Configurando listener del BovinoBloc...');
    _bovinoBlocSubscription = _bovinoBloc.stream.listen((state) {
      // Verificar que el BLoC no esté cerrado antes de agregar eventos
      if (isClosed) {
        _logger.d('⚠️ BLoC cerrado - ignorando evento del BovinoBloc');
        return;
      }
      
      _logger.d('📡 Estado del BovinoBloc recibido: ${state.runtimeType}');
      
      if (state is BovinoSubmitted) {
        // Frame enviado exitosamente - agregar a lista de pendientes
        _logger.i('📋 Frame agregado a lista de pendientes: ${state.frameId}');
        _pendingFrames.add(state.frameId);
        _logger.i('📊 Total de frames pendientes: ${_pendingFrames.length}');
        
        // Disparar evento interno para actualizar estado
        add(_UpdateProcessingStateEvent());
      } else if (state is BovinoResult) {
        // Frame procesado exitosamente - esto NO debería pasar aquí
        // porque el polling maneja los resultados
        _logger.w('⚠️ BovinoResult recibido en listener - esto no debería pasar');
      } else if (state is BovinoError) {
        _logger.e('❌ Error en BovinoBloc: ${state.failure.message}');
      } else if (state is BovinoSubmitting) {
        _logger.d('📤 BovinoBloc enviando frame: ${state.framePath}');
      } else if (state is BovinoChecking) {
        _logger.d('🔍 BovinoBloc verificando frame: ${state.frameId}');
      } else {
        _logger.d('📡 Estado del BovinoBloc: ${state.runtimeType}');
      }
    });
    _logger.i('✅ Listener del BovinoBloc configurado correctamente');
  }

  /// Handler para actualizar estado de procesamiento
  void _onUpdateProcessingState(
    _UpdateProcessingStateEvent event,
    Emitter<FrameAnalysisState> emit,
  ) {
    // Solo emitir FrameAnalysisProcessing si no hay resultados exitosos
    if (_results.isEmpty) {
      emit(FrameAnalysisProcessing(
        pendingFrames: _pendingFrames.length,
        processedFrames: _processedFrames,
        successfulFrames: _successfulFrames,
      ));
    } else {
      _logger.d('📊 Actualización de estado ignorada - manteniendo resultado exitoso');
    }
  }

  /// Handler para emitir resultado
  void _onEmitResult(
    _EmitResultEvent event,
    Emitter<FrameAnalysisState> emit,
  ) {
    _logger.i('🎯 Emitiendo resultado exitoso: ${event.result['raza']} - ${event.result['confianza']}');
    emit(FrameAnalysisSuccess(result: event.result));
  }

  /// Handler para limpiar completamente el estado (cuando se sale al home)
  void _onClearFrameAnalysisState(
    ClearFrameAnalysisStateEvent event,
    Emitter<FrameAnalysisState> emit,
  ) {
    _logger.i('🧹 Limpiando completamente el estado del FrameAnalysisBloc...');
    
    // Cancelar timers
    _frameTimer?.cancel();
    _statusTimer?.cancel();
    
    // Limpiar todo
    _pendingFrames.clear();
    _results.clear();
    _processedFrames = 0;
    _successfulFrames = 0;
    
    // Volver al estado inicial
    emit(FrameAnalysisInitial());
    
    _logger.i('✅ Estado del FrameAnalysisBloc limpiado completamente');
  }

  @override
  Future<void> close() {
    _logger.i('🔌 Cerrando FrameAnalysisBloc');
    _frameTimer?.cancel();
    _statusTimer?.cancel();
    _bovinoBlocSubscription?.cancel();
    return super.close();
  }
} 