import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import 'tensorflow_server_datasource.dart';

/// Implementación concreta del datasource para comunicación con servidor TensorFlow
///
/// Proporciona funcionalidades para:
/// - Envío de frames al servidor para análisis asíncrono
/// - Verificación de estado de frames
/// - Verificación de estado del servidor
/// - Manejo robusto de errores de conexión
class TensorFlowServerDataSourceImpl implements TensorFlowServerDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  /// Constructor que requiere las dependencias necesarias
  ///
  /// [dio] - Cliente HTTP para comunicación REST
  TensorFlowServerDataSourceImpl(this._dio);

  @override
  Future<String> submitFrame(String framePath) async {
    try {
      _logger.i('📤 Enviando frame para análisis asíncrono: $framePath');

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
        throw NetworkFailure(
          message: 'Error del servidor: ${response.statusCode}',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      _logger.e('❌ Error de red al enviar frame: ${e.message}');
      throw NetworkFailure(
        message: 'Error de conexión: ${e.message}',
        code: e.response?.statusCode.toString(),
      );
    } catch (e) {
      _logger.e('❌ Error inesperado al enviar frame: $e');
      throw UnknownFailure(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> checkFrameStatus(String frameId) async {
    try {
      _logger.d('🔍 Verificando estado de frame: $frameId');

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
}
