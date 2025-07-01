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

/// Evento para enviar un frame para análisis asíncrono
class SubmitFrameForAnalysis extends BovinoEvent {
  final String framePath;

  const SubmitFrameForAnalysis(this.framePath);

  @override
  List<Object?> get props => [framePath];
}

/// Evento para verificar el estado de un frame
class CheckFrameStatus extends BovinoEvent {
  final String frameId;

  const CheckFrameStatus(this.frameId);

  @override
  List<Object?> get props => [frameId];
}

/// Evento para limpiar el estado actual
class ClearBovinoState extends BovinoEvent {}

// Estados para BovinoBloc
abstract class BovinoState extends Equatable {
  const BovinoState();

  @override
  List<Object?> get props => [];
}

class BovinoInitial extends BovinoState {}

class BovinoSubmitting extends BovinoState {
  final String framePath;

  const BovinoSubmitting(this.framePath);

  @override
  List<Object?> get props => [framePath];
}

class BovinoSubmitted extends BovinoState {
  final String frameId;

  const BovinoSubmitted(this.frameId);

  @override
  List<Object?> get props => [frameId];
}

class BovinoChecking extends BovinoState {
  final String frameId;

  const BovinoChecking(this.frameId);

  @override
  List<Object?> get props => [frameId];
}

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

// Bloc para manejar análisis de bovinos con flujo asíncrono
class BovinoBloc extends Bloc<BovinoEvent, BovinoState> {
  final BovinoRepository repository;
  final Logger _logger = Logger();

  BovinoBloc({required this.repository}) : super(BovinoInitial()) {
    on<SubmitFrameForAnalysis>(_onSubmitFrameForAnalysis);
    on<CheckFrameStatus>(_onCheckFrameStatus);
    on<ClearBovinoState>(_onClearBovinoState);
  }

  /// Maneja el envío de un frame para análisis asíncrono
  Future<void> _onSubmitFrameForAnalysis(
    SubmitFrameForAnalysis event,
    Emitter<BovinoState> emit,
  ) async {
    try {
      _logger.i('📤 Enviando frame para análisis: ${event.framePath}');
      emit(BovinoSubmitting(event.framePath));

      final result = await repository.submitFrameForAnalysis(event.framePath);

      result.fold(
        (failure) {
          _logger.e('❌ Error al enviar frame: ${failure.message}');
          emit(BovinoError(failure));
        },
        (frameId) {
          _logger.i('✅ Frame enviado exitosamente: $frameId');
          emit(BovinoSubmitted(frameId));
        },
      );
    } catch (e) {
      _logger.e('❌ Error inesperado al enviar frame: $e');
      emit(BovinoError(UnknownFailure(message: e.toString())));
    }
  }

  /// Maneja la verificación del estado de un frame
  Future<void> _onCheckFrameStatus(
    CheckFrameStatus event,
    Emitter<BovinoState> emit,
  ) async {
    try {
      _logger.d('🔍 Verificando estado de frame: ${event.frameId}');
      emit(BovinoChecking(event.frameId));

      final result = await repository.checkFrameStatus(event.frameId);

      result.fold(
        (failure) {
          _logger.e('❌ Error al verificar estado: ${failure.message}');
          emit(BovinoError(failure));
        },
        (bovino) {
          if (bovino != null) {
            _logger.i('✅ Análisis completado: ${bovino.raza}');
            emit(BovinoResult(bovino));
          } else {
            _logger.d('⏳ Frame aún procesándose: ${event.frameId}');
            // Mantener el estado actual para continuar polling
            emit(BovinoChecking(event.frameId));
          }
        },
      );
    } catch (e) {
      _logger.e('❌ Error inesperado al verificar estado: $e');
      emit(BovinoError(UnknownFailure(message: e.toString())));
    }
  }

  /// Limpia el estado actual del bloc
  void _onClearBovinoState(
    ClearBovinoState event,
    Emitter<BovinoState> emit,
  ) {
    _logger.i('🧹 Limpiando estado del BovinoBloc');
    emit(BovinoInitial());
  }
}
