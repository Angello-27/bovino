import 'package:dartz/dartz.dart';
import '../entities/bovino_entity.dart';
import '../../core/errors/failures.dart';

abstract class BovinoRepository {
  /// Analiza una imagen de ganado bovino y retorna la información del animal
  Future<Either<Failure, BovinoEntity>> analizarImagen(String imagenPath);
  
  /// Obtiene información adicional sobre una raza específica
  Future<Either<Failure, Map<String, dynamic>>> obtenerInfoRaza(String raza);
  
  /// Guarda el análisis en el historial local
  Future<Either<Failure, void>> guardarAnalisis(BovinoEntity bovino);
  
  /// Obtiene el historial de análisis
  Future<Either<Failure, List<BovinoEntity>>> obtenerHistorial();
  
  /// Elimina un análisis del historial
  Future<Either<Failure, void>> eliminarAnalisis(String id);
  
  /// Valida si una raza es conocida
  Future<Either<Failure, bool>> validarRaza(String raza);
  
  /// Obtiene sugerencias de razas similares
  Future<Either<Failure, List<String>>> obtenerRazasSimilares(String raza);
} 