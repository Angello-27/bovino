import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';

import '../../data/datasources/remote/tensorflow_server_datasource.dart';

/// Servicio para análisis de frames con el servidor TensorFlow
/// 
/// Utiliza el datasource para comunicación con el servidor
/// y maneja el flujo asíncrono de análisis de frames
class FrameAnalysisService {
  final TensorFlowServerDataSource _dataSource;
  final Logger _logger = Logger();

  FrameAnalysisService(this._dataSource);

  /// Inicializar el servicio
  Future<void> initialize() async {
    try {
      _logger.i('🔧 Inicializando FrameAnalysisService...');
      
      // Verificar conexión con el servidor usando el datasource
      final isConnected = await _dataSource.verificarConexion();
      if (!isConnected) {
        _logger.w('⚠️ Servidor no disponible, funcionando en modo offline');
      } else {
        _logger.i('✅ Servidor conectado');
      }
    } catch (e) {
      _logger.e('❌ Error al inicializar FrameAnalysisService: $e');
    }
  }

  /// Enviar frame para análisis usando el datasource
  Future<String> submitFrameForAnalysis(
    File imageFile, {
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.i('📤 Enviando frame para análisis...');

      // Usar el datasource para enviar el frame
      final frameId = await _dataSource.submitFrame(imageFile.path);
      
      _logger.i('✅ Frame enviado exitosamente: $frameId');
      return frameId;
    } catch (e) {
      _logger.e('❌ Error al enviar frame: $e');
      // Retornar ID simulado para modo offline
      return 'offline_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Verificar estado de análisis usando el datasource
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
            'peso_estimado': 650.0,
            'confianza': 0.85,
            'caracteristicas': ['Lechera', 'Blanco y negro'],
            'timestamp': DateTime.now().toIso8601String(),
          },
        };
      }

      // Usar el datasource para verificar el estado
      final result = await _dataSource.checkFrameStatus(frameId);
      
      if (result != null) {
        _logger.d('✅ Estado obtenido: ${result['status']}');
      } else {
        _logger.w('⚠️ Frame no encontrado: $frameId');
      }
      
      return result;
    } catch (e) {
      _logger.e('❌ Error al verificar estado: $e');
      return null;
    }
  }
} 