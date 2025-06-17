import 'dart:io';
import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../../core/errors/failures.dart';
import '../../../domain/entities/bovino_entity.dart';

class TensorFlowAnalysisDataSource {
  static const String _modelPath = 'assets/models/cattle_classification.tflite';
  static const String _labelsPath = 'assets/models/cattle_labels.txt';
  
  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isInitialized = false;

  // Configuración del modelo
  static const int _inputSize = 224;
  static const int _numClasses = 20; // Número de razas de ganado

  Future<void> initialize() async {
    try {
      // Cargar modelo
      _interpreter = await Interpreter.fromAsset(_modelPath);
      
      // Cargar etiquetas
      _labels = await _loadLabels();
      
      _isInitialized = true;
    } catch (e) {
      throw AnalysisFailure(
        message: 'Error al inicializar TensorFlow Lite: $e',
        code: 'TFLITE_INIT_ERROR',
      );
    }
  }

  Future<List<String>> _loadLabels() async {
    try {
      final labelsFile = File(_labelsPath);
      final labels = await labelsFile.readAsLines();
      return labels;
    } catch (e) {
      // Etiquetas por defecto si no se encuentra el archivo
      return [
        'Holstein', 'Angus', 'Brahman', 'Hereford', 'Simmental',
        'Charolais', 'Limousin', 'Jersey', 'Guernsey', 'Ayrshire',
        'Brown Swiss', 'Shorthorn', 'Gelbvieh', 'Red Angus',
        'Belted Galloway', 'Highland', 'Longhorn', 'Wagyu',
        'Piedmontese', 'Chianina'
      ];
    }
  }

  Future<BovinoEntity> analyzeImage(String imagePath) async {
    if (!_isInitialized) {
      throw AnalysisFailure(
        message: 'TensorFlow Lite no está inicializado',
        code: 'TFLITE_NOT_INITIALIZED',
      );
    }

    try {
      // Cargar y preprocesar imagen
      final input = await _preprocessImage(imagePath);
      
      // Preparar tensor de salida
      final output = List.filled(_numClasses, 0.0);
      
      // Ejecutar inferencia
      _interpreter.run(input, output);
      
      // Postprocesar resultados
      return _postprocessResults(output, imagePath);
    } catch (e) {
      throw AnalysisFailure(
        message: 'Error en análisis de imagen: $e',
        code: 'TFLITE_ANALYSIS_ERROR',
      );
    }
  }

  Future<List<List<List<double>>>> _preprocessImage(String imagePath) async {
    try {
      // Cargar imagen
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('No se pudo decodificar la imagen');
      }
      
      // Redimensionar imagen
      final resizedImage = img.copyResize(
        image,
        width: _inputSize,
        height: _inputSize,
      );
      
      // Convertir a tensor normalizado
      final tensor = List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) => List.generate(
            3,
            (c) {
              final pixel = resizedImage.getPixel(x, y);
              double value;
              switch (c) {
                case 0: // R
                  value = img.getRed(pixel) / 255.0;
                  break;
                case 1: // G
                  value = img.getGreen(pixel) / 255.0;
                  break;
                case 2: // B
                  value = img.getBlue(pixel) / 255.0;
                  break;
                default:
                  value = 0.0;
              }
              return value;
            },
          ),
        ),
      );
      
      return tensor;
    } catch (e) {
      throw Exception('Error en preprocesamiento: $e');
    }
  }

  BovinoEntity _postprocessResults(List<double> output, String imagePath) {
    // Encontrar la clase con mayor probabilidad
    int maxIndex = 0;
    double maxProbability = output[0];
    
    for (int i = 1; i < output.length; i++) {
      if (output[i] > maxProbability) {
        maxProbability = output[i];
        maxIndex = i;
      }
    }
    
    // Obtener raza y confianza
    final raza = _labels[maxIndex];
    final confianza = maxProbability;
    
    // Estimar peso basado en la raza y confianza
    final pesoEstimado = _estimateWeight(raza, confianza);
    
    // Generar descripción
    final descripcion = _generateDescription(raza, confianza, pesoEstimado);
    
    // Generar características
    final caracteristicas = _generateCharacteristics(raza);
    
    return BovinoEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      raza: raza,
      pesoEstimado: pesoEstimado,
      confianza: confianza,
      descripcion: descripcion,
      caracteristicas: caracteristicas,
      fechaAnalisis: DateTime.now(),
      imagenPath: imagePath,
    );
  }

  double _estimateWeight(String raza, double confianza) {
    // Pesos promedio por raza (en kg)
    final Map<String, double> pesosPromedio = {
      'Holstein': 650.0,
      'Angus': 750.0,
      'Brahman': 700.0,
      'Hereford': 600.0,
      'Simmental': 800.0,
      'Charolais': 850.0,
      'Limousin': 750.0,
      'Jersey': 450.0,
      'Guernsey': 500.0,
      'Ayrshire': 550.0,
      'Brown Swiss': 650.0,
      'Shorthorn': 700.0,
      'Gelbvieh': 750.0,
      'Red Angus': 750.0,
      'Belted Galloway': 600.0,
      'Highland': 500.0,
      'Longhorn': 600.0,
      'Wagyu': 700.0,
      'Piedmontese': 800.0,
      'Chianina': 900.0,
    };
    
    final pesoBase = pesosPromedio[raza] ?? 650.0;
    
    // Ajustar peso basado en confianza
    final variacion = (confianza - 0.5) * 0.2; // ±10% variación
    return pesoBase * (1 + variacion);
  }

  String _generateDescription(String raza, double confianza, double peso) {
    final confianzaTexto = confianza > 0.8 
        ? 'alta confianza' 
        : confianza > 0.6 
            ? 'confianza moderada' 
            : 'baja confianza';
    
    return 'Animal identificado como $raza con $confianzaTexto. '
           'Peso estimado: ${peso.toStringAsFixed(1)} kg. '
           'El análisis se realizó usando un modelo de aprendizaje automático optimizado para identificación de razas bovinas.';
  }

  List<String> _generateCharacteristics(String raza) {
    // Características típicas por raza
    final Map<String, List<String>> caracteristicas = {
      'Holstein': [
        'Patrón blanco y negro distintivo',
        'Cabeza blanca con manchas negras',
        'Cuerpo bien proporcionado',
        'Ubres desarrolladas',
        'Patas negras'
      ],
      'Angus': [
        'Pelaje negro uniforme',
        'Sin cuernos (polled)',
        'Cabeza ancha',
        'Musculatura desarrollada',
        'Patas fuertes'
      ],
      'Brahman': [
        'Joroba prominente en el cuello',
        'Orejas largas y caídas',
        'Pelaje gris claro',
        'Piel suelta y arrugada',
        'Adaptado a clima cálido'
      ],
      // Agregar más razas según sea necesario
    };
    
    return caracteristicas[raza] ?? [
      'Características de la raza identificada',
      'Análisis basado en patrones visuales',
      'Estimación de peso realizada',
      'Identificación automática por IA'
    ];
  }

  void dispose() {
    _interpreter.close();
  }
} 