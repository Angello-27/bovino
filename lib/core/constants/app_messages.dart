class AppMessages {
  // Mensajes de cámara
  static const String cameraPermission =
      'Se requieren permisos de cámara para usar esta función';
  static const String noCameras = 'No se encontraron cámaras disponibles';
  static const String cameraInitializing = 'Inicializando cámara...';
  static const String cameraReady = 'Cámara lista para capturar frames';
  static const String capturingFrames = 'Capturando frames automáticamente';
  static const String captureError = 'Error al capturar frame';
  static const String cameraInitializationError =
      'Error al inicializar la cámara';
  static const String permissionDeniedError = 'Permiso denegado';

  // Mensajes de permisos
  static const String cameraPermissionGranted = 'Permiso de cámara concedido';
  static const String cameraPermissionDenied = 'Permiso de cámara denegado';
  static const String storagePermissionGranted =
      'Permiso de almacenamiento concedido';
  static const String storagePermissionDenied =
      'Permiso de almacenamiento denegado';
  static const String mediaPermissionsGranted = 'Permisos de medios concedidos';
  static const String mediaPermissionsDenied = 'Permisos de medios denegados';
  static const String mediaPermissionsAlreadyGranted =
      'Permisos de medios ya concedidos';
  static const String storagePermissionAlreadyGranted =
      'Permiso de almacenamiento ya concedido';

  // Mensajes de temas
  static const String themeLight = 'Claro';
  static const String themeDark = 'Oscuro';
  static const String themeLightDescription = 'Tema claro para uso diurno';
  static const String themeDarkDescription = 'Tema oscuro para uso nocturno';

  // Mensajes de análisis
  static const String analyzing = 'Analizando frame del bovino...';
  static const String errorAnalysis = 'Error al analizar el frame';
  static const String waitingForResult = 'Esperando resultado del servidor...';
  static const String frameAnalysisError = 'Error al analizar el frame';
  static const String fileNotFoundError = 'El archivo no existe';
  static const String serverConnectionError =
      'Error de conexión con el servidor';
  static const String requiredFieldError = 'Campo requerido no encontrado';

  // Mensajes de red
  static const String networkError = 'Error de conexión. Verifica tu internet';
  static const String serverError =
      'Error de conexión con el servidor TensorFlow';

  // Mensajes de resultados
  static const String noBovinoDetected =
      'No se detectó ganado bovino en el frame';
  static const String bovinoDetected = 'Ganado bovino detectado';
  static const String confidenceLow = 'Confianza baja en la identificación';
  static const String confidenceMedium = 'Confianza media en la identificación';
  static const String confidenceHigh = 'Alta confianza en la identificación';

  // Mensajes de error específicos
  static const String frameTooLarge = 'El frame es demasiado grande';
  static const String invalidFrame = 'Frame inválido';
  static const String serverTimeout = 'Tiempo de espera agotado del servidor';
  static const String serverUnavailable = 'Servidor no disponible';

  // Mensajes de UI
  static const String retry = 'Reintentar';
  static const String ok = 'Aceptar';
  static const String cancel = 'Cancelar';
  static const String close = 'Cerrar';
  static const String settings = 'Configuración';
  static const String about = 'Acerca de';

  // Mensajes de estado
  static const String ready = 'Listo';
  static const String processing = 'Procesando...';
  static const String error = 'Error';
  static const String success = 'Éxito';
  static const String warning = 'Advertencia';
  static const String info = 'Información';

  // Mensajes de validación
  static const String invalidUrl = 'URL inválida';
  static const String invalidPort = 'Puerto inválido';
  static const String connectionFailed = 'Falló la conexión';
  static const String permissionDenied = 'Permiso denegado';

  // Mensajes de ayuda
  static const String helpCamera = 'Apunta la cámara hacia el ganado bovino';
  static const String helpConnection =
      'Asegúrate de que el servidor esté ejecutándose';
  static const String helpPermissions =
      'Concede permisos de cámara en la configuración';

  // Mensajes de configuración
  static const String configServerUrl = 'URL del servidor TensorFlow';
  static const String configFrameInterval = 'Intervalo de captura de frames';
  static const String configImageQuality = 'Calidad de imagen';

  // Mensajes de debug
  static const String debugFrameSent = 'Frame enviado al servidor';
  static const String debugFrameReceived = 'Frame recibido del servidor';

  // Mensajes de UI específicos
  static const String changeTheme = 'Cambiar tema';
  static const String intelligentAnalysis = 'Análisis Inteligente';
  static const String startAnalysis = 'Iniciar Análisis';
  static const String stopAnalysis = 'Detener';
  static const String mainFeatures = 'Características Principales';
  static const String liveCamera = 'Cámara en Vivo';
  static const String autoCapture = 'Captura automática';
  static const String advancedAI = 'IA Avanzada';
  static const String tensorFlow = 'TensorFlow';
  static const String fastAnalysis = 'Análisis Rápido';
  static const String instantResults = 'Resultados instantáneos';
  static const String analyzingStatus = 'ANALIZANDO';
  static const String waiting = 'En espera';
  static const String completed = 'Completado';
  static const String analysisResult = 'Resultado del Análisis';
  static const String breed = 'Raza';
  static const String estimatedWeight = 'Peso estimado';
  static const String confidence = 'Confianza';
  static const String notDetected = 'No detectada';
  static const String notAvailable = 'No disponible';
  static const String kg = 'kg';
  static const String percent = '%';
}
