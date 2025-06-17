import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/bovino_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';

abstract class RemoteDataSource {
  Future<BovinoModel> analizarImagen(String imagenPath);
  Future<Map<String, dynamic>> obtenerInfoRaza(String raza);
}

class OpenAIDataSource implements RemoteDataSource {
  final Dio _dio;

  OpenAIDataSource(this._dio) {
    _dio.options.headers['Authorization'] = 'Bearer ${AppConstants.openaiApiKey}';
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = AppConstants.timeoutSeconds;
    _dio.options.receiveTimeout = AppConstants.timeoutSeconds;
  }

  @override
  Future<BovinoModel> analizarImagen(String imagenPath) async {
    try {
      // Validar API key
      if (AppConstants.openaiApiKey == 'TU_API_KEY_AQUI') {
        throw ApiKeyFailure(
          message: 'Por favor configura tu API key de OpenAI en lib/core/constants/app_constants.dart',
          code: 'API_KEY_NOT_CONFIGURED',
        );
      }

      final imagen = File(imagenPath);
      final bytes = await imagen.readAsBytes();
      
      // Verificar tamaño de imagen
      if (bytes.length > AppConstants.maxImageSize * 1024) {
        throw ValidationFailure(
          message: 'La imagen es demasiado grande. Máximo ${AppConstants.maxImageSize}KB',
          code: 'IMAGE_TOO_LARGE',
        );
      }
      
      final base64Image = base64Encode(bytes);

      const prompt = '''
Analiza esta imagen de ganado bovino y proporciona la siguiente información en formato JSON:

1. Identifica la raza del bovino (ej: Holstein, Angus, Brahman, Hereford, Simmental, etc.)
2. Estima el peso en kilogramos basándote en el tamaño, edad aparente y características visibles
3. Proporciona un nivel de confianza en la identificación (0-1)
4. Describe las características principales del animal
5. Lista las características físicas observables

Consideraciones para el análisis:
- Observa el color del pelaje, patrón de manchas, forma de la cabeza
- Evalúa el tamaño corporal, musculatura, y proporciones
- Considera la edad aparente del animal
- Identifica características distintivas de la raza

Responde únicamente con un JSON válido con esta estructura:
{
  "raza": "nombre_raza",
  "peso_estimado": peso_en_kg,
  "confianza": nivel_confianza,
  "descripcion": "descripción_detallada",
  "caracteristicas": ["característica1", "característica2", ...]
}
''';

      final response = await _dio.post(
        '${AppConstants.openaiBaseUrl}/chat/completions',
        data: {
          'model': AppConstants.openaiModel,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image',
                  },
                },
              ],
            },
          ],
          'max_tokens': AppConstants.maxTokens,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      
      // Extraer JSON de la respuesta
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      if (jsonMatch == null) {
        throw AnalysisFailure(
          message: 'No se pudo extraer JSON de la respuesta de OpenAI',
          code: 'INVALID_JSON_RESPONSE',
        );
      }

      final jsonString = jsonMatch.group(0);
      final jsonData = json.decode(jsonString!);
      
      // Crear modelo con datos adicionales
      final bovinoModel = BovinoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        raza: jsonData['raza'] ?? 'Desconocida',
        pesoEstimado: (jsonData['peso_estimado'] ?? 0.0).toDouble(),
        confianza: (jsonData['confianza'] ?? 0.0).toDouble(),
        descripcion: jsonData['descripcion'] ?? '',
        caracteristicas: List<String>.from(jsonData['caracteristicas'] ?? []),
        fechaAnalisis: DateTime.now(),
        imagenPath: imagenPath,
      );
      
      return bovinoModel;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiKeyFailure(
          message: 'API key de OpenAI inválida. Verifica tu configuración.',
          code: 'INVALID_API_KEY',
        );
      } else if (e.response?.statusCode == 429) {
        throw ServerFailure(
          message: 'Límite de uso de OpenAI alcanzado. Intenta más tarde.',
          code: 'RATE_LIMIT_EXCEEDED',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw NetworkFailure(
          message: 'Tiempo de conexión agotado. Verifica tu internet.',
          code: 'CONNECTION_TIMEOUT',
        );
      } else {
        throw NetworkFailure(
          message: 'Error de conexión: ${e.message}',
          code: 'NETWORK_ERROR',
        );
      }
    } catch (e) {
      throw AnalysisFailure(
        message: 'Error al analizar imagen: $e',
        code: 'ANALYSIS_ERROR',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> obtenerInfoRaza(String raza) async {
    try {
      final prompt = '''
Proporciona información detallada sobre la raza bovina "$raza" incluyendo:
- Peso promedio de adultos (machos y hembras)
- Características físicas principales
- Origen y distribución geográfica
- Usos principales (leche, carne, doble propósito)
- Características de producción
- Adaptabilidad climática

Responde en formato JSON con esta estructura:
{
  "nombre": "nombre_raza",
  "peso_promedio_macho": peso_kg,
  "peso_promedio_hembra": peso_kg,
  "caracteristicas_fisicas": ["característica1", "característica2"],
  "origen": "país/región de origen",
  "usos": ["uso1", "uso2"],
  "produccion": "descripción de producción",
  "adaptabilidad": "descripción de adaptabilidad"
}
''';

      final response = await _dio.post(
        '${AppConstants.openaiBaseUrl}/chat/completions',
        data: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'max_tokens': 500,
        },
      );

      final content = response.data['choices'][0]['message']['content'];
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
      
      if (jsonMatch != null) {
        return json.decode(jsonMatch.group(0)!);
      }
      
      return {'error': 'No se pudo obtener información de la raza'};
    } catch (e) {
      return {'error': 'Error al obtener información de la raza: $e'};
    }
  }
} 