/// Contrato abstracto para comunicación con servidor TensorFlow
///
/// Define las operaciones disponibles para:
/// - Envío de frames para análisis asíncrono
/// - Verificación de estado de frames
/// - Verificación de conexión
/// - Gestión de HTTP Polling
abstract class TensorFlowServerDataSource {
  /// Envía un frame para análisis asíncrono.
  ///
  /// [framePath] - Ruta del frame a enviar
  /// Retorna el ID del frame para consulta posterior
  Future<String> submitFrame(String framePath);

  /// Verifica el estado de un frame enviado.
  ///
  /// [frameId] - ID del frame a consultar
  /// Retorna el estado y resultado del análisis
  Future<Map<String, dynamic>?> checkFrameStatus(String frameId);

  /// Verifica la conexión con el servidor TensorFlow.
  ///
  /// Retorna `true` si el servidor está disponible y respondiendo.
  Future<bool> verificarConexion();
}
