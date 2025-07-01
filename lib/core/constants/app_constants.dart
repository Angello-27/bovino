class AppConstants {
  // Configuración del servidor TensorFlow
  // Para dispositivo físico en la misma red local
  static const String serverBaseUrl = 'http://192.168.0.6:8000';
  static const String apiBaseUrl = 'http://192.168.0.6:8000';

  // Configuración de la aplicación
  static const String appName = 'Bovino IA';
  static const String appVersion = '2.0.0';
  static const String appDescription =
      'Análisis de ganado bovino con cámara en vivo y TensorFlow';

  // Configuración de la cámara
  static const int maxImageSize = 1024; // Tamaño máximo de imagen en KB
  static const double imageQuality = 0.8; // Calidad de imagen (0.0 - 1.0)
  static const Duration frameCaptureInterval = Duration(
    seconds: 3,
  ); // Intervalo entre capturas de frames
  static const Duration maxFrameProcessingTime = Duration(
    seconds: 10,
  ); // Tiempo máximo de procesamiento

  // Configuración de análisis asíncrono
  static const Duration timeoutSeconds = Duration(seconds: 30);
  static const Duration pollingInterval = Duration(seconds: 2);
  static const int maxRetryAttempts = 3;
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Configuración de frames
  static const int maxFramesInMemory = 5; // Máximo frames en memoria
  static const bool enableFrameCompression = true;
  static const double frameCompressionQuality = 0.7;

  // Configuración de robustez
  static const bool enableOfflineMode = true; // Permitir funcionamiento sin servidor
  static const bool enableGracefulDegradation = true; // Degradación elegante

  // Razas de ganado conocidas para validación
  static const List<String> knownBreeds = [
    'Holstein',
    'Angus',
    'Brahman',
    'Hereford',
    'Simmental',
    'Charolais',
    'Limousin',
    'Jersey',
    'Guernsey',
    'Ayrshire',
    'Brown Swiss',
    'Shorthorn',
    'Gelbvieh',
    'Red Angus',
    'Belted Galloway',
    'Highland',
    'Longhorn',
    'Wagyu',
    'Piedmontese',
    'Chianina',
  ];

  // Configuración de resolución de cámara
  static const Map<String, dynamic> cameraResolutions = {
    'low': {'width': 640, 'height': 480, 'quality': 0.5},
    'medium': {'width': 1280, 'height': 720, 'quality': 0.7},
    'high': {'width': 1920, 'height': 1080, 'quality': 0.8},
  };
}

class ApiEndpoints {
  // Endpoints para análisis asíncrono
  static const String healthCheck = '/health';
  static const String submitFrame = '/submit-frame';
  static const String checkStatus = '/check-status';
}

class ValidationRules {
  static const int minImageSize = 100; // KB
  static const int maxImageSize = 2048; // KB
  static const double minConfidence = 0.5;
  static const double maxConfidence = 1.0;
  static const int maxFrameWidth = 1920;
  static const int maxFrameHeight = 1080;
}
