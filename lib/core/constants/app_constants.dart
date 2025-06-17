class AppConstants {
  // Configuración de la aplicación
  static const String appName = 'Bovino IA';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Análisis de ganado bovino con IA';
  
  // Configuración de API
  static const String openaiBaseUrl = 'https://api.openai.com/v1';
  static const String openaiModel = 'gpt-4-vision-preview';
  static const String openaiApiKey = 'TU_API_KEY_AQUI'; // Configurar en producción
  
  // Configuración de cámara
  static const int maxImageSize = 1024; // KB
  static const double imageQuality = 0.8;
  static const int maxTokens = 1000;
  static const int timeoutSeconds = 30;
  
  // Configuración de UI
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 4.0;
  
  // Colores de la aplicación
  static const int primaryColor = 0xFF4CAF50;
  static const int secondaryColor = 0xFF81C784;
  static const int backgroundColor = 0xFFF5F5F5;
  static const int textColor = 0xFF212121;
  static const int errorColor = 0xFFE57373;
  static const int successColor = 0xFF81C784;
  static const int warningColor = 0xFFFFB74D;
  
  // Tiempos de animación
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Mensajes de error
  static const String errorNetwork = 'Error de conexión. Verifica tu internet.';
  static const String errorCamera = 'Error al acceder a la cámara.';
  static const String errorAnalysis = 'Error al analizar la imagen.';
  static const String errorApiKey = 'API key no configurada.';
  static const String errorTimeout = 'Tiempo de espera agotado.';
  
  // Mensajes de éxito
  static const String successAnalysis = 'Análisis completado exitosamente.';
  static const String successImageCapture = 'Imagen capturada correctamente.';
  
  // Estados de carga
  static const String loadingAnalysis = 'Analizando imagen...';
  static const String loadingCamera = 'Inicializando cámara...';
  static const String loadingNetwork = 'Conectando con el servidor...';
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