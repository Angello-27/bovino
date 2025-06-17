import 'package:dartz/dartz.dart';
import '../entities/bovino_entity.dart';
import '../repositories/bovino_repository.dart';
import '../../core/errors/failures.dart';

class ObtenerHistorialUseCase {
  final BovinoRepository _repository;

  ObtenerHistorialUseCase(this._repository);

  Future<Either<Failure, List<BovinoEntity>>> call() async {
    return await _repository.obtenerHistorial();
  }
} 