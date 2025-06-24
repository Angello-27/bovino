import 'package:dartz/dartz.dart';
import '../entities/bovino_entity.dart';
import '../../core/errors/failures.dart';

/// Contrato del repositorio para operaciones de análisis de bovinos
///
/// Define las operaciones disponibles para el análisis de frames
/// siguiendo Clean Architecture y el patrón Repository.
abstract class BovinoRepository {
  /// Analiza un frame de ganado bovino y retorna información detallada.
  ///
  /// [framePath] - Ruta del frame a analizar
  ///
  /// Retorna un [Either<Failure, BovinoEntity>] donde:
  /// - [Left] contiene un [Failure] si ocurre un error
  /// - [Right] contiene un [BovinoEntity] con el análisis exitoso
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final resultado = await repository.analizarFrame('path/to/frame.jpg');
  /// resultado.fold(
  ///   (failure) => print('Error: ${failure.message}'),
  ///   (bovino) => print('Raza: ${bovino.raza}'),
  /// );
  /// ```
  Future<Either<Failure, BovinoEntity>> analizarFrame(String framePath);
}
