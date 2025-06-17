import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../errors/failures.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../domain/usecases/analizar_imagen_usecase.dart';

class AnalysisQueueService {
  final AnalizarImagenUseCase _analizarImagenUseCase;
  final StreamController<AnalysisResult> _resultStreamController = StreamController<AnalysisResult>.broadcast();
  final StreamController<AnalysisStatus> _statusStreamController = StreamController<AnalysisStatus>.broadcast();
  
  final Queue<AnalysisTask> _analysisQueue = Queue<AnalysisTask>();
  Timer? _processingTimer;
  bool _isProcessing = false;
  int _maxConcurrentAnalyses = 1; // Procesar uno a la vez para evitar rate limiting
  int _activeAnalyses = 0;
  DateTime? _lastAnalysisTime;

  AnalysisQueueService(this._analizarImagenUseCase) {
    _startProcessing();
  }

  // Getters
  Stream<AnalysisResult> get resultStream => _resultStreamController.stream;
  Stream<AnalysisStatus> get statusStream => _statusStreamController.stream;
  bool get isProcessing => _isProcessing;
  int get queueLength => _analysisQueue.length;
  int get activeAnalyses => _activeAnalyses;

  /// Agrega una imagen a la cola de análisis
  void enqueueAnalysis(String imagePath, {String? taskId}) {
    final task = AnalysisTask(
      id: taskId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );

    _analysisQueue.add(task);
    _updateStatus();
  }

  /// Inicia el procesamiento de la cola
  void _startProcessing() {
    _processingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _processNextTask();
    });
  }

  /// Procesa la siguiente tarea en la cola
  Future<void> _processNextTask() async {
    if (_analysisQueue.isEmpty || _activeAnalyses >= _maxConcurrentAnalyses) {
      return;
    }

    // Verificar rate limiting
    if (_lastAnalysisTime != null) {
      final timeSinceLastAnalysis = DateTime.now().difference(_lastAnalysisTime!);
      if (timeSinceLastAnalysis < const Duration(seconds: 2)) {
        return; // Esperar más tiempo entre análisis
      }
    }

    final task = _analysisQueue.removeFirst();
    _activeAnalyses++;
    _lastAnalysisTime = DateTime.now();
    _updateStatus();

    try {
      // Verificar que el archivo existe
      final file = File(task.imagePath);
      if (!await file.exists()) {
        _emitResult(AnalysisResult(
          taskId: task.id,
          success: false,
          error: 'Archivo de imagen no encontrado',
          timestamp: DateTime.now(),
        ));
        return;
      }

      // Realizar análisis
      final result = await _analizarImagenUseCase(task.imagePath);
      
      result.fold(
        (failure) => _emitResult(AnalysisResult(
          taskId: task.id,
          success: false,
          error: failure.message,
          timestamp: DateTime.now(),
        )),
        (bovino) => _emitResult(AnalysisResult(
          taskId: task.id,
          success: true,
          bovino: bovino,
          timestamp: DateTime.now(),
        )),
      );
    } catch (e) {
      _emitResult(AnalysisResult(
        taskId: task.id,
        success: false,
        error: 'Error inesperado: $e',
        timestamp: DateTime.now(),
      ));
    } finally {
      _activeAnalyses--;
      _updateStatus();
    }
  }

  /// Emite un resultado de análisis
  void _emitResult(AnalysisResult result) {
    _resultStreamController.add(result);
  }

  /// Actualiza el estado del servicio
  void _updateStatus() {
    _statusStreamController.add(AnalysisStatus(
      isProcessing: _isProcessing,
      queueLength: _analysisQueue.length,
      activeAnalyses: _activeAnalyses,
      lastAnalysisTime: _lastAnalysisTime,
    ));
  }

  /// Limpia la cola de análisis
  void clearQueue() {
    _analysisQueue.clear();
    _updateStatus();
  }

  /// Pausa el procesamiento
  void pauseProcessing() {
    _isProcessing = false;
    _updateStatus();
  }

  /// Reanuda el procesamiento
  void resumeProcessing() {
    _isProcessing = true;
    _updateStatus();
  }

  /// Configura el número máximo de análisis concurrentes
  void setMaxConcurrentAnalyses(int max) {
    _maxConcurrentAnalyses = max;
  }

  /// Obtiene estadísticas del servicio
  Map<String, dynamic> getStatistics() {
    return {
      'queueLength': _analysisQueue.length,
      'activeAnalyses': _activeAnalyses,
      'maxConcurrentAnalyses': _maxConcurrentAnalyses,
      'isProcessing': _isProcessing,
      'lastAnalysisTime': _lastAnalysisTime?.toIso8601String(),
    };
  }

  /// Libera recursos
  void dispose() {
    _processingTimer?.cancel();
    _analysisQueue.clear();
    _resultStreamController.close();
    _statusStreamController.close();
  }
}

/// Clase para representar una tarea de análisis
class AnalysisTask {
  final String id;
  final String imagePath;
  final DateTime timestamp;

  AnalysisTask({
    required this.id,
    required this.imagePath,
    required this.timestamp,
  });
}

/// Clase para representar el resultado de un análisis
class AnalysisResult {
  final String taskId;
  final bool success;
  final BovinoEntity? bovino;
  final String? error;
  final DateTime timestamp;

  AnalysisResult({
    required this.taskId,
    required this.success,
    this.bovino,
    this.error,
    required this.timestamp,
  });
}

/// Clase para representar el estado del servicio
class AnalysisStatus {
  final bool isProcessing;
  final int queueLength;
  final int activeAnalyses;
  final DateTime? lastAnalysisTime;

  AnalysisStatus({
    required this.isProcessing,
    required this.queueLength,
    required this.activeAnalyses,
    this.lastAnalysisTime,
  });
} 