import '../../models/bovino_model.dart';

/// Contrato abstracto para comunicación con servidor TensorFlow
///
/// Define las operaciones disponibles para:
/// - Análisis de frames
/// - Verificación de conexión
/// - Notificaciones asíncronas
/// - Gestión de WebSocket
abstract class TensorFlowServerDataSource {
  /// Analiza un frame de ganado bovino y retorna información detallada.
  ///
  /// [framePath] - Ruta del frame a analizar
  ///
  /// Retorna un [BovinoModel] con la información analizada.
  ///
  /// Lanza [NetworkFailure] si hay problemas de conexión.
  Future<BovinoModel> analizarFrame(String framePath);

  /// Verifica la conexión con el servidor TensorFlow.
  ///
  /// Retorna `true` si el servidor está disponible y respondiendo.
  Future<bool> verificarConexion();
}
