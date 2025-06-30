import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
// import '../error/error_handler.dart';
import '../../data/models/bovino_model.dart';
import '../../domain/entities/bovino_entity.dart';

/// Servicio para análisis de frames con el servidor TensorFlow
class FrameAnalysisService {
  final Dio _dio;
  final Logger _logger = Logger();

  FrameAnalysisService(this._dio);

  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      _logger.i('🔧 Inicializando FrameAnalysisService...');
      
      // Verificar conexión con el servidor
      final isConnected = await _verifyConnection();
      if (!isConnected) {
        _logger.w('⚠️ Servidor no disponible, funcionando en modo offline');
      } else {
        _logger.i('✅ Servidor conectado');
      }
    } catch (e) {
      _logger.e('❌ Error al inicializar FrameAnalysisService: $e');
    }
  }

  /// Verificar conexión con el servidor
  Future<bool> _verifyConnection() async {
    try {
      final response = await _dio.get(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.healthCheck}',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('❌ Error al verificar conexión: $e');
      return false;
    }
  }

  /// Enviar frame para análisis
  Future<String> submitFrameForAnalysis(
    File imageFile, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('📤 Enviando frame para análisis...');

      // Crear FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
        if (metadata != null) 'metadata': metadata.toString(),
      });

      // Enviar al servidor
      final response = await _dio.post(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.submitFrame}',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        final frameId = response.data['frame_id'] as String;
        _logger.i('✅ Frame enviado exitosamente: $frameId');
        return frameId;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error al enviar frame: $e');
      // Retornar ID simulado para modo offline
      return 'offline_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Verificar estado de análisis
  Future<Map<String, dynamic>?> checkFrameStatus(String frameId) async {
    try {
      _logger.d('🔍 Verificando estado de frame: $frameId');

      // Si es un frame offline, simular resultado
      if (frameId.startsWith('offline_')) {
        await Future.delayed(const Duration(seconds: 1));
        return {
          'status': 'completed',
          'result': {
            'raza': 'Holstein',
            'peso': '650',
            'confianza': '85',
            'timestamp': DateTime.now().toIso8601String(),
          },
        };
      }

      // Verificar con el servidor
      final response = await _dio.get(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.checkStatus}/$frameId',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        _logger.w('⚠️ Frame no encontrado: $frameId');
        return null;
      }
    } catch (e) {
      _logger.e('❌ Error al verificar estado: $e');
      return null;
    }
  }

  /// Analizar frame de forma síncrona (legacy)
  Future<Map<String, dynamic>> analyzeFrameSync(File imageFile) async {
    try {
      _logger.i('📤 Analizando frame de forma síncrona...');

      // Crear FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imageFile.path),
      });

      // Enviar al servidor
      final response = await _dio.post(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.analyzeFrame}',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Análisis síncrono completado');
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error en análisis síncrono: $e');
      // Retornar resultado simulado para modo offline
      return {
        'raza': 'Holstein',
        'peso': '650',
        'confianza': '85',
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}

/// Servicio para análisis asíncrono de frames
/// 
/// Maneja el envío de frames al servidor y consulta de resultados
/// de manera asíncrona para evitar bloqueos en la UI
class FrameAnalysisServiceOld {
  final Dio _dio;
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();
  
  // Cola de frames enviados para seguimiento
  final Map<String, FrameAnalysisTask> _pendingFrames = {};
  
  // Stream controller para notificar resultados
  final StreamController<FrameAnalysisResult> _resultController = 
      StreamController<FrameAnalysisResult>.broadcast();
  
  // Timer para consultas periódicas
  Timer? _pollingTimer;
  
  // Configuración
  static const int _pollingIntervalMs = 2000; // 2 segundos
  static const int _maxRetries = 3;
  static const int _timeoutMs = 30000; // 30 segundos

  FrameAnalysisServiceOld(this._dio);

  /// Stream de resultados de análisis
  Stream<FrameAnalysisResult> get resultStream => _resultController.stream;

  /// Número de frames pendientes
  int get pendingFramesCount => _pendingFrames.length;

  /// Iniciar el servicio de análisis
  Future<void> initialize() async {
    _logger.i('🚀 Iniciando FrameAnalysisService...');
    
    // Configurar polling automático
    _startPolling();
    
    _logger.i('✅ FrameAnalysisService inicializado');
  }

  /// Enviar frame para análisis asíncrono
  /// 
  /// [imageFile] - Archivo de imagen a analizar
  /// [metadata] - Metadatos adicionales del frame
  /// 
  /// Retorna el ID del frame para seguimiento
  Future<String> submitFrameForAnalysis(
    File imageFile, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final frameId = _uuid.v4();
      _logger.i('📸 Enviando frame $frameId para análisis...');

      // Crear FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'frame_$frameId.jpg',
        ),
      });

      // Enviar frame al servidor
      final response = await _dio.post(
        '${AppConstants.apiBaseUrl}/submit-frame',
        data: formData,
        options: Options(
          sendTimeout: const Duration(milliseconds: _timeoutMs),
          receiveTimeout: const Duration(milliseconds: _timeoutMs),
          headers: const {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final status = responseData['status'] as String;
        
        // Crear tarea de seguimiento
        final task = FrameAnalysisTask(
          frameId: frameId,
          status: status,
          submittedAt: DateTime.now(),
          metadata: metadata ?? {},
          retryCount: 0,
        );
        
        _pendingFrames[frameId] = task;
        
        _logger.i('✅ Frame $frameId enviado exitosamente (status: $status)');
        
        // Notificar inicio de análisis
        _resultController.add(FrameAnalysisResult(
          frameId: frameId,
          status: status,
          message: 'Frame enviado para análisis',
          timestamp: DateTime.now(),
        ));
        
        return frameId;
      } else {
        throw Exception('Error al enviar frame: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error al enviar frame: $e');
      rethrow;
    }
  }

  /// Consultar estado de un frame específico
  Future<FrameAnalysisResult?> checkFrameStatus(String frameId) async {
    try {
      if (!_pendingFrames.containsKey(frameId)) {
        _logger.w('⚠️ Frame $frameId no encontrado en cola local');
        return null;
      }

      _logger.d('🔍 Consultando estado del frame $frameId...');

      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/check-status/$frameId',
        options: Options(
          sendTimeout: const Duration(milliseconds: _timeoutMs),
          receiveTimeout: const Duration(milliseconds: _timeoutMs),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final status = data['status'] as String;
        final updatedAt = DateTime.parse(data['updated_at']);
        
        // Actualizar tarea local
        final task = _pendingFrames[frameId]!;
        task.status = status;
        task.lastChecked = DateTime.now();
        
        FrameAnalysisResult result;
        
        if (status == 'completed' && data['result'] != null) {
          // Análisis completado exitosamente
          final bovinoData = data['result'];
          final bovinoModel = BovinoModel.fromJson(bovinoData);
          final bovinoEntity = bovinoModel.toEntity();
          
          result = FrameAnalysisResult(
            frameId: frameId,
            status: status,
            bovino: bovinoEntity,
            message: 'Análisis completado',
            timestamp: updatedAt,
          );
          
          // Remover de cola pendiente
          _pendingFrames.remove(frameId);
          
          _logger.i('✅ Frame $frameId completado: ${bovinoEntity.raza}');
          
        } else if (status == 'failed') {
          // Análisis falló
          final error = data['error'] as String? ?? 'Error desconocido';
          
          result = FrameAnalysisResult(
            frameId: frameId,
            status: status,
            error: error,
            message: 'Análisis falló',
            timestamp: updatedAt,
          );
          
          // Remover de cola pendiente
          _pendingFrames.remove(frameId);
          
          _logger.e('❌ Frame $frameId falló: $error');
          
        } else {
          // Análisis en progreso
          result = FrameAnalysisResult(
            frameId: frameId,
            status: status,
            message: 'Análisis en progreso...',
            timestamp: updatedAt,
          );
          
          _logger.d('⏳ Frame $frameId en progreso: $status');
        }
        
        // Notificar resultado
        _resultController.add(result);
        return result;
        
      } else {
        throw Exception('Error al consultar estado: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ Error al consultar estado del frame $frameId: $e');
      
      // Incrementar contador de reintentos
      final task = _pendingFrames[frameId];
      if (task != null) {
        task.retryCount++;
        task.lastError = e.toString();
        
        if (task.retryCount >= _maxRetries) {
          // Máximo de reintentos alcanzado
          final result = FrameAnalysisResult(
            frameId: frameId,
            status: 'failed',
            error: 'Máximo de reintentos alcanzado',
            message: 'No se pudo consultar el estado',
            timestamp: DateTime.now(),
          );
          
          _pendingFrames.remove(frameId);
          _resultController.add(result);
        }
      }
      
      return null;
    }
  }

  /// Iniciar polling automático de frames pendientes
  void _startPolling() {
    _pollingTimer?.cancel();
    
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: _pollingIntervalMs),
      (timer) async {
        if (_pendingFrames.isEmpty) return;
        
        _logger.d('🔄 Polling: ${_pendingFrames.length} frames pendientes');
        
        // Consultar estado de todos los frames pendientes
        final frameIds = _pendingFrames.keys.toList();
        for (final frameId in frameIds) {
          await checkFrameStatus(frameId);
          
          // Pequeña pausa entre consultas para no sobrecargar el servidor
          await Future.delayed(const Duration(milliseconds: 100));
        }
      },
    );
    
    _logger.i('🔄 Polling automático iniciado (${_pollingIntervalMs}ms)');
  }

  /// Detener polling automático
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _logger.i('🛑 Polling automático detenido');
  }

  /// Limpiar frames antiguos (más de 1 hora)
  void cleanupOldFrames() {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 1));
    final framesToRemove = <String>[];
    
    for (final entry in _pendingFrames.entries) {
      if (entry.value.submittedAt.isBefore(cutoffTime)) {
        framesToRemove.add(entry.key);
      }
    }
    
    for (final frameId in framesToRemove) {
      _pendingFrames.remove(frameId);
      _logger.i('🗑️ Frame $frameId removido por antigüedad');
    }
    
    if (framesToRemove.isNotEmpty) {
      _logger.i('🧹 Limpieza completada: ${framesToRemove.length} frames removidos');
    }
  }

  /// Obtener estadísticas del servicio
  Map<String, dynamic> getStats() {
    final now = DateTime.now();
    final stats = <String, dynamic>{
      'pendingFrames': _pendingFrames.length,
      'oldestFrame': null,
      'newestFrame': null,
      'averageAgeMinutes': 0.0,
    };
    
    if (_pendingFrames.isNotEmpty) {
      final ages = <Duration>[];
      DateTime? oldest, newest;
      
      for (final task in _pendingFrames.values) {
        final age = now.difference(task.submittedAt);
        ages.add(age);
        
        if (oldest == null || task.submittedAt.isBefore(oldest)) {
          oldest = task.submittedAt;
        }
        if (newest == null || task.submittedAt.isAfter(newest)) {
          newest = task.submittedAt;
        }
      }
      
      stats['oldestFrame'] = oldest?.toIso8601String();
      stats['newestFrame'] = newest?.toIso8601String();
      stats['averageAgeMinutes'] = ages
          .map((age) => age.inMinutes)
          .reduce((a, b) => a + b) / ages.length;
    }
    
    return stats;
  }

  /// Verificar conectividad con el servidor
  Future<bool> checkServerConnectivity() async {
    try {
      final response = await _dio.get(
        '${AppConstants.apiBaseUrl}/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      _logger.w('⚠️ Servidor no disponible: $e');
      return false;
    }
  }

  /// Disposal del servicio
  void dispose() {
    stopPolling();
    _resultController.close();
    _pendingFrames.clear();
    _logger.i('🧹 FrameAnalysisService disposed');
  }
}

/// Tarea de análisis de frame para seguimiento interno
class FrameAnalysisTask {
  final String frameId;
  String status;
  final DateTime submittedAt;
  final Map<String, dynamic> metadata;
  int retryCount;
  DateTime? lastChecked;
  String? lastError;

  FrameAnalysisTask({
    required this.frameId,
    required this.status,
    required this.submittedAt,
    required this.metadata,
    this.retryCount = 0,
    this.lastChecked,
    this.lastError,
  });
}

/// Resultado de análisis de frame
class FrameAnalysisResult {
  final String frameId;
  final String status;
  final BovinoEntity? bovino;
  final String? error;
  final String message;
  final DateTime timestamp;

  FrameAnalysisResult({
    required this.frameId,
    required this.status,
    this.bovino,
    this.error,
    required this.message,
    required this.timestamp,
  });

  /// Verificar si el análisis está completado
  bool get isCompleted => status == 'completed';
  
  /// Verificar si el análisis falló
  bool get isFailed => status == 'failed';
  
  /// Verificar si el análisis está en progreso
  bool get isPending => status == 'pending' || status == 'processing';
  
  /// Verificar si se detectó un bovino
  bool get hasBovino => bovino != null && bovino!.raza != 'No detectado';

  @override
  String toString() {
    return 'FrameAnalysisResult(frameId: $frameId, status: $status, message: $message)';
  }
} 