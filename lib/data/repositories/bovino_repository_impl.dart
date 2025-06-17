import 'package:dartz/dartz.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../domain/repositories/bovino_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/remote/remote_datasource.dart';
import '../datasources/local/local_datasource.dart';
import '../models/bovino_model.dart';

class BovinoRepositoryImpl implements BovinoRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  BovinoRepositoryImpl({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, BovinoEntity>> analizarImagen(String imagenPath) async {
    try {
      final bovinoModel = await _remoteDataSource.analizarImagen(imagenPath);
      
      // Guardar en local después del análisis exitoso
      await _localDataSource.guardarAnalisis(bovinoModel);
      
      return Right(bovinoModel.toEntity());
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AnalysisFailure(
        message: 'Error inesperado al analizar imagen: $e',
        code: 'UNEXPECTED_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, List<BovinoEntity>>> obtenerHistorial() async {
    try {
      final historial = await _localDataSource.obtenerHistorial();
      final entities = historial.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(StorageFailure(
        message: 'Error al obtener historial: $e',
        code: 'HISTORIAL_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> eliminarAnalisis(String id) async {
    try {
      await _localDataSource.eliminarAnalisis(id);
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(StorageFailure(
        message: 'Error al eliminar análisis: $e',
        code: 'DELETE_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> limpiarHistorial() async {
    try {
      await _localDataSource.limpiarHistorial();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(StorageFailure(
        message: 'Error al limpiar historial: $e',
        code: 'CLEAR_ERROR',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> obtenerInfoRaza(String raza) async {
    try {
      final info = await _remoteDataSource.obtenerInfoRaza(raza);
      return Right(info);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(AnalysisFailure(
        message: 'Error al obtener información de raza: $e',
        code: 'BREED_INFO_ERROR',
      ));
    }
  }
} 