import 'dart:async';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Servicio para manejar la conectividad y estado del servidor
class ConnectivityService {
  final Logger _logger = Logger();
  final Dio _dio;
  
  bool _isServerAvailable = false;
  bool _isCheckingConnection = false;
  Timer? _healthCheckTimer;
  
  // Stream para notificar cambios en la conectividad
  final StreamController<bool> _connectivityController = 
      StreamController<bool>.broadcast();
  
  Stream<bool> get connectivityStream => _connectivityController.stream;
  bool get isServerAvailable => _isServerAvailable;
  bool get isCheckingConnection => _isCheckingConnection;

  ConnectivityService(this._dio) {
    _initializeHealthCheck();
  }

  /// Inicializa el health check periódico
  void _initializeHealthCheck() {
    if (AppConstants.enableOfflineMode) {
      _healthCheckTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => checkServerHealth(),
      );
    }
  }

  /// Verifica la salud del servidor
  Future<bool> checkServerHealth() async {
    if (_isCheckingConnection) return _isServerAvailable;
    
    _isCheckingConnection = true;
    
    try {
      _logger.d('🔍 Verificando salud del servidor...');
      
      final response = await _dio.get(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.healthCheck}',
        options: Options(
          sendTimeout: AppConstants.connectionTimeout,
          receiveTimeout: AppConstants.connectionTimeout,
        ),
      );
      
      final isHealthy = response.statusCode == 200;
      _updateServerStatus(isHealthy);
      
      _logger.i('✅ Servidor saludable: $isHealthy');
      return isHealthy;
    } catch (e) {
      _logger.w('⚠️ Servidor no disponible: $e');
      _updateServerStatus(false);
      return false;
    } finally {
      _isCheckingConnection = false;
    }
  }

  /// Actualiza el estado del servidor y notifica a los listeners
  void _updateServerStatus(bool isAvailable) {
    if (_isServerAvailable != isAvailable) {
      _isServerAvailable = isAvailable;
      _connectivityController.add(isAvailable);
      
      _logger.i(
        isAvailable 
          ? '🟢 Servidor conectado' 
          : '🔴 Servidor desconectado'
      );
    }
  }

  /// Verifica la conectividad de forma síncrona
  Future<bool> isConnected() async {
    return await checkServerHealth();
  }

  /// Intenta reconectar al servidor
  Future<bool> reconnect() async {
    _logger.i('🔄 Intentando reconectar al servidor...');
    
    for (int attempt = 1; attempt <= AppConstants.maxRetryAttempts; attempt++) {
      _logger.d('Intento $attempt de ${AppConstants.maxRetryAttempts}');
      
      final isConnected = await checkServerHealth();
      if (isConnected) {
        _logger.i('✅ Reconexión exitosa');
        return true;
      }
      
      if (attempt < AppConstants.maxRetryAttempts) {
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    
    _logger.w('❌ No se pudo reconectar después de ${AppConstants.maxRetryAttempts} intentos');
    return false;
  }

  /// Dispone del servicio
  void dispose() {
    _healthCheckTimer?.cancel();
    _connectivityController.close();
    _logger.i('🔌 ConnectivityService disposed');
  }
} 