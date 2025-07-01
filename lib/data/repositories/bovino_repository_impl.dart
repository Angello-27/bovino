import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../domain/repositories/bovino_repository.dart';
import '../datasources/remote/tensorflow_server_datasource.dart';
import '../models/bovino_model.dart';

/// Implementación del repositorio para operaciones de análisis de bovinos
///
/// Maneja la lógica de negocio para:
/// - Envío de frames para análisis asíncrono
/// - Verificación de estado de frames
/// - Conversión de datos entre capas
class BovinoRepositoryImpl implements BovinoRepository {
  final TensorFlowServerDataSource remoteDataSource;

  BovinoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> submitFrameForAnalysis(String framePath) async {
    try {
      final frameId = await remoteDataSource.submitFrame(framePath);
      return Right(frameId);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BovinoEntity?>> checkFrameStatus(String frameId) async {
    try {
      final statusData = await remoteDataSource.checkFrameStatus(frameId);
      
      if (statusData == null) {
        // Frame no encontrado o aún procesándose
        return const Right(null);
      }

      final status = statusData['status'] as String?;
      
      if (status == 'completed') {
        // Frame procesado exitosamente
        final resultData = statusData['result'] as Map<String, dynamic>?;
        if (resultData != null) {
          final bovinoModel = BovinoModel.fromJson(resultData);
          return Right(bovinoModel.toEntity());
        }
      } else if (status == 'processing') {
        // Frame aún en procesamiento
        return const Right(null);
      } else if (status == 'failed') {
        // Frame falló en el procesamiento
        final errorMessage = statusData['error'] as String? ?? 'Error desconocido';
        return Left(ServerFailure(message: errorMessage));
      }

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
