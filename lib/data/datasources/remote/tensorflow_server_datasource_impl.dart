import 'dart:io';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../models/bovino_model.dart';
import 'tensorflow_server_datasource.dart';

/// Implementación concreta del datasource para comunicación con servidor TensorFlow
///
/// Proporciona funcionalidades para:
/// - Envío de frames al servidor para análisis
/// - Verificación de estado del servidor
/// - Recepción de notificaciones asíncronas via WebSocket
/// - Manejo robusto de errores de conexión
class TensorFlowServerDataSourceImpl implements TensorFlowServerDataSource {
  final Dio _dio;
  final WebSocketChannel _websocket;
  final Logger _logger = Logger();

  /// Constructor que requiere las dependencias necesarias
  ///
  /// [dio] - Cliente HTTP para comunicación REST
  /// [websocket] - Canal WebSocket para notificaciones
  TensorFlowServerDataSourceImpl(this._dio, this._websocket);

  @override
  Future<BovinoModel> analizarFrame(String framePath) async {
    try {
      _logger.i('📤 Enviando frame para análisis: $framePath');

      // Verificar que el archivo existe
      final file = File(framePath);
      if (!await file.exists()) {
        _logger.e('❌ Archivo no encontrado: $framePath');
        throw ValidationFailure(
          message: 'El archivo no existe: $framePath',
          code: 'FILE_NOT_FOUND',
        );
      }

      // Crear FormData para enviar la imagen
      final formData = FormData.fromMap({
        'frame': await MultipartFile.fromFile(framePath),
      });

      // Realizar petición POST al servidor
      final response = await _dio.post(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.analyzeFrame}',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        _logger.i('✅ Frame analizado exitosamente');
        return BovinoModel.fromJson(response.data);
      } else {
        _logger.e('❌ Error del servidor: ${response.statusCode}');
        throw NetworkFailure(
          message: 'Error en el servidor: ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ Error de red al analizar frame: ${e.message}');
      throw NetworkFailure(
        message: 'Error de conexión: ${e.message}',
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      _logger.e('❌ Error inesperado al analizar frame: $e');
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<bool> verificarConexion() async {
    try {
      _logger.i('🔍 Verificando conexión con el servidor...');

      final response = await _dio.get(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.healthCheck}',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final isConnected = response.statusCode == 200;
      _logger.i(
        isConnected ? '✅ Servidor conectado' : '❌ Servidor no disponible',
      );

      return isConnected;
    } catch (e) {
      _logger.e('❌ Error al verificar conexión: $e');
      return false;
    }
  }

  @override
  Stream<BovinoModel> get notificacionesStream {
    return _websocket.stream
        .map((data) {
          _logger.i('📨 Notificación recibida: $data');
          return BovinoModel.fromJson(data);
        })
        .handleError((error) {
          _logger.e('❌ Error en stream de notificaciones: $error');
          throw NetworkFailure(message: 'Error en WebSocket: $error');
        });
  }

  @override
  Future<void> enviarMensaje(String mensaje) async {
    try {
      _logger.i('📤 Enviando mensaje: $mensaje');
      _websocket.sink.add(mensaje);
    } catch (e) {
      _logger.e('❌ Error al enviar mensaje: $e');
      throw NetworkFailure(message: 'Error al enviar mensaje: $e');
    }
  }

  @override
  Future<void> cerrarConexion() async {
    try {
      _logger.i('🔌 Cerrando conexión WebSocket...');
      await _websocket.sink.close();
      _logger.i('✅ Conexión WebSocket cerrada');
    } catch (e) {
      _logger.e('❌ Error al cerrar WebSocket: $e');
    }
  }
}
