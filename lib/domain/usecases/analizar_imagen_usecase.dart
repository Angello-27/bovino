import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/bovino_entity.dart';
import '../repositories/bovino_repository.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';

@injectable
class AnalizarImagenUseCase {
  final BovinoRepository repository;

  const AnalizarImagenUseCase(this.repository);

  Future<Either<Failure, BovinoEntity>> call(String imagenPath) async {
    try {
      // Validaciones básicas
      if (imagenPath.isEmpty) {
        return const Left(
          ValidationFailure(message: 'La ruta de la imagen no puede estar vacía'),
        );
      }

      // Analizar imagen
      final resultado = await repository.analizarImagen(imagenPath);
      
      return resultado.fold(
        (failure) => Left(failure),
        (bovino) async {
          // Guardar en historial local
          await repository.guardarAnalisis(bovino);
          return Right(bovino);
        },
      );
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Error inesperado: $e'),
      );
    }
  }
} 