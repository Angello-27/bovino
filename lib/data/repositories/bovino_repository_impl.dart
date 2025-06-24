import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../domain/repositories/bovino_repository.dart';
import '../datasources/remote/tensorflow_server_datasource.dart';

class BovinoRepositoryImpl implements BovinoRepository {
  final TensorFlowServerDataSource remoteDataSource;

  BovinoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BovinoEntity>> analizarFrame(String framePath) async {
    try {
      final model = await remoteDataSource.analizarFrame(framePath);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Error al analizar el frame: $e'));
    }
  }
}
