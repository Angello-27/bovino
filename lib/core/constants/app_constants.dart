class AppConstants {
  // Configuración de OpenAI
  static const String openaiApiKey = 'TU_API_KEY_AQUI'; // Reemplaza con tu API key
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiModel = 'gpt-4-vision-preview';
  
  // Configuración de la aplicación
  static const String appName = 'Bovino IA';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Análisis de ganado bovino con IA';
  
  // Configuración de la cámara
  static const int maxImageSize = 1024; // Tamaño máximo de imagen en KB
  static const double imageQuality = 0.8; // Calidad de imagen (0.0 - 1.0)
  static const Duration minCaptureInterval = Duration(seconds: 2); // Intervalo mínimo entre capturas
  static const Duration defaultFrameInterval = Duration(seconds: 3); // Intervalo por defecto para captura automática
  static const int defaultMaxFrames = 10; // Número máximo de frames por sesión
  
  // Configuración de análisis
  static const int maxTokens = 1000;
  static const Duration timeoutSeconds = Duration(seconds: 30);
  static const Duration analysisRateLimit = Duration(seconds: 2); // Rate limiting para análisis
  static const int maxConcurrentAnalyses = 1; // Análisis concurrentes máximos
  
  // Configuración de la cola de análisis
  static const Duration queueProcessingInterval = Duration(milliseconds: 500);
  static const int maxQueueSize = 50; // Tamaño máximo de la cola
  
  // Mensajes de la aplicación
  static const Map<String, String> messages = {
    'cameraPermission': 'Se requieren permisos de cámara para usar esta función',
    'noCameras': 'No se encontraron cámaras disponibles',
    'analyzing': 'Analizando imagen del bovino...',
    'errorAnalysis': 'Error al analizar la imagen',
    'networkError': 'Error de conexión. Verifica tu internet',
    'apiKeyError': 'Error con la API key de OpenAI',
    'captureError': 'Error al capturar imagen',
    'queueFull': 'Cola de análisis llena. Espera un momento',
    'rateLimitExceeded': 'Demasiadas solicitudes. Espera un momento',
    'cameraInitializing': 'Inicializando cámara...',
    'cameraReady': 'Cámara lista para capturar',
    'capturingFrames': 'Capturando frames automáticamente',
    'processingQueue': 'Procesando cola de análisis',
  };
  
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
  
  // Configuración de UI
  static const Map<String, dynamic> uiConfig = {
    'primaryColor': 0xFF4CAF50,
    'secondaryColor': 0xFF81C784,
    'backgroundColor': 0xFFF5F5F5,
    'textColor': 0xFF212121,
    'borderRadius': 12.0,
    'padding': 16.0,
    'margin': 8.0,
    'cameraAspectRatio': 4/3,
    'previewAspectRatio': 16/9,
  };

  // Configuración de resolución de cámara
  static const Map<String, dynamic> cameraResolutions = {
    'low': {
      'width': 640,
      'height': 480,
      'quality': 0.5,
    },
    'medium': {
      'width': 1280,
      'height': 720,
      'quality': 0.7,
    },
    'high': {
      'width': 1920,
      'height': 1080,
      'quality': 0.8,
    },
    'ultra': {
      'width': 3840,
      'height': 2160,
      'quality': 0.9,
    },
  };

  // Configuración de almacenamiento
  static const Map<String, dynamic> storageConfig = {
    'maxHistorialSize': 100,
    'autoCleanupDays': 30,
    'compressionEnabled': true,
    'compressionQuality': 0.8,
  };
}

class ApiEndpoints {
  static const String chatCompletions = '/chat/completions';
  static const String models = '/models';
}

class StorageKeys {
  static const String userPreferences = 'user_preferences';
  static const String analysisHistory = 'analysis_history';
  static const String apiKey = 'api_key';
}

class ValidationRules {
  static const int minImageSize = 100; // KB
  static const int maxImageSize = 2048; // KB
  static const double minConfidence = 0.5;
  static const double maxConfidence = 1.0;
  static const int minWeight = 50; // kg
  static const int maxWeight = 1500; // kg
} 