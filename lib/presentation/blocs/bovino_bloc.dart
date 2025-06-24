import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../domain/repositories/bovino_repository.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../core/errors/failures.dart';

// Eventos para BovinoBloc
abstract class BovinoEvent extends Equatable {
  const BovinoEvent();

  @override
  List<Object?> get props => [];
}

class AnalizarFrameEvent extends BovinoEvent {
  final String imagePath;

  const AnalizarFrameEvent(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Estados para BovinoBloc
abstract class BovinoState extends Equatable {
  const BovinoState();

  @override
  List<Object?> get props => [];
}

class BovinoInitial extends BovinoState {}

class BovinoAnalyzing extends BovinoState {}

class BovinoResult extends BovinoState {
  final BovinoEntity bovino;

  const BovinoResult(this.bovino);

  @override
  List<Object?> get props => [bovino];
}

class BovinoError extends BovinoState {
  final Failure failure;

  const BovinoError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// Bloc para manejar análisis de bovinos
class BovinoBloc extends Bloc<BovinoEvent, BovinoState> {
  final BovinoRepository repository;
  final Logger _logger = Logger();

  BovinoBloc({required this.repository}) : super(BovinoInitial()) {
    on<AnalizarFrameEvent>(_onAnalizarFrame);
  }

  Future<void> _onAnalizarFrame(
    AnalizarFrameEvent event,
    Emitter<BovinoState> emit,
  ) async {
    try {
      emit(BovinoAnalyzing());
      _logger.i('Analizando frame: ${event.imagePath}');

      final resultado = await repository.analizarFrame(event.imagePath);

      resultado.fold(
        (failure) {
          _logger.e('Error al analizar frame: ${failure.message}');
          emit(BovinoError(failure));
        },
        (bovino) {
          _logger.i(
            'Análisis exitoso - Raza: ${bovino.raza}, Peso: ${bovino.pesoFormateado}',
          );
          emit(BovinoResult(bovino));
        },
      );
    } catch (e) {
      _logger.e('Error inesperado en BovinoBloc: $e');
      emit(BovinoError(UnknownFailure(message: e.toString())));
    }
  }
}
