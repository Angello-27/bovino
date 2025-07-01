import 'package:dartz/dartz.dart';
import '../entities/bovino_entity.dart';
import '../../core/errors/failures.dart';

/// Contrato del repositorio para operaciones de análisis de bovinos
///
/// Define las operaciones disponibles para el análisis de frames
/// siguiendo Clean Architecture y el patrón Repository.
/// 
/// El flujo asíncrono reemplaza completamente el análisis síncrono:
/// 1. submitFrameForAnalysis - Envía frame para análisis
/// 2. checkFrameStatus - Consulta estado del análisis
abstract class BovinoRepository {
  /// Envía un frame para análisis asíncrono.
  ///
  /// [framePath] - Ruta del frame a enviar
  /// Retorna `Either<Failure, String>` con el ID del frame o error
  Future<Either<Failure, String>> submitFrameForAnalysis(String framePath);

  /// Verifica el estado de un frame enviado.
  ///
  /// [frameId] - ID del frame a consultar
  /// Retorna `Either<Failure, BovinoEntity?>` con el resultado o error
  Future<Either<Failure, BovinoEntity?>> checkFrameStatus(String frameId);
}
