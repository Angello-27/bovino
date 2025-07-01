import 'dart:io';
import 'package:dio/dio.dart';
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
/// - Manejo robusto de errores de conexión
class TensorFlowServerDataSourceImpl implements TensorFlowServerDataSource {
  final Dio _dio;
  final Logger _logger = Logger();

  /// Constructor que requiere las dependencias necesarias
  ///
  /// [dio] - Cliente HTTP para comunicación REST
  TensorFlowServerDataSourceImpl(this._dio);

  @override
  Future<BovinoModel> analizarFrame(String framePath) async {
    try {
      _logger.i('📤 Enviando frame para análisis: $framePath');
      _logger.i('🌐 URL del servidor: ${AppConstants.serverBaseUrl}${ApiEndpoints.analyzeFrame}');

      // Verificar que el archivo existe
      final file = File(framePath);
      if (!await file.exists()) {
        _logger.e('❌ Archivo no encontrado: $framePath');
        throw ValidationFailure(
          message: 'El archivo no existe: $framePath',
          code: 'FILE_NOT_FOUND',
        );
      }
      
      // Verificar tamaño del archivo
      final fileSize = await file.length();
      _logger.i('📏 Tamaño del archivo: $fileSize bytes');
      
      if (fileSize == 0) {
        _logger.e('❌ Archivo vacío: $framePath');
        throw ValidationFailure(
          message: 'El archivo está vacío: $framePath',
          code: 'EMPTY_FILE',
        );
      }

      // Crear FormData para enviar la imagen
      final formData = FormData.fromMap({
        'frame': await MultipartFile.fromFile(framePath),
      });

      // Realizar petición POST al servidor
      _logger.i('🚀 Enviando petición POST al servidor...');
      final response = await _dio.post(
        '${AppConstants.serverBaseUrl}${ApiEndpoints.analyzeFrame}',
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      
      _logger.i('📡 Respuesta recibida: ${response.statusCode}');

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
}
