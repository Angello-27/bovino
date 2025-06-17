import 'package:dartz/dartz.dart';
import '../repositories/bovino_repository.dart';
import '../../core/errors/failures.dart';

class EliminarAnalisisUseCase {
  final BovinoRepository _repository;

  EliminarAnalisisUseCase(this._repository);

  Future<Either<Failure, void>> call(String id) async {
    return await _repository.eliminarAnalisis(id);
  }
} 