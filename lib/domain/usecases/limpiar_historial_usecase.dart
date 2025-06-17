import 'package:dartz/dartz.dart';
import '../repositories/bovino_repository.dart';
import '../../core/errors/failures.dart';

class LimpiarHistorialUseCase {
  final BovinoRepository _repository;

  LimpiarHistorialUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return await _repository.limpiarHistorial();
  }
} 