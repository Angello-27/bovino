import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';

/// Módulo para inyección de dependencias WebSocket
/// Sigue Clean Architecture y separación de responsabilidades
class WebSocketInjection {
  static final GetIt _getIt = GetIt.instance;
  static final Logger _logger = Logger();

  /// Configura WebSocket para notificaciones asíncronas
  static Future<void> setup() async {
    try {
      final channel = WebSocketChannel.connect(
        Uri.parse(AppConstants.websocketUrl),
      );

      _getIt.registerSingleton<WebSocketChannel>(channel);
      _logger.i('🔌 WebSocket Connected to ${AppConstants.websocketUrl}');
    } catch (e) {
      _logger.e('❌ WebSocket Connection Error: $e');
      // Registrar un WebSocket mock para evitar errores
      _getIt.registerSingleton<WebSocketChannel>(
        WebSocketChannel.connect(Uri.parse('ws://localhost')),
      );
    }
  }

  /// Obtiene la instancia de WebSocket
  static WebSocketChannel get websocket => _getIt<WebSocketChannel>();

  /// Limpia las dependencias WebSocket
  static Future<void> dispose() async {
    try {
      final websocket = _getIt<WebSocketChannel>();
      await websocket.sink.close();
      _logger.i('🔌 WebSocket disposed successfully');
    } catch (e) {
      _logger.e('❌ Error disposing WebSocket: $e');
    }
  }
}
