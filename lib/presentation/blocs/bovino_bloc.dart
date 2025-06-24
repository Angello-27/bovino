import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/bovino_repository.dart';

// Eventos para BovinoBloc
abstract class BovinoEvent {}

class AnalizarFrameEvent extends BovinoEvent {
  final String imagePath;
  AnalizarFrameEvent(this.imagePath);
}

// Estados para BovinoBloc
abstract class BovinoState {}

class BovinoInitial extends BovinoState {}

class BovinoLoading extends BovinoState {}

class BovinoSuccess extends BovinoState {
  final dynamic result;
  BovinoSuccess(this.result);
}

class BovinoFailure extends BovinoState {
  final String error;
  BovinoFailure(this.error);
}

// Bloc para manejar análisis de bovinos
class BovinoBloc extends Bloc<BovinoEvent, BovinoState> {
  final BovinoRepository repository;

  BovinoBloc({required this.repository}) : super(BovinoInitial()) {
    on<AnalizarFrameEvent>((event, emit) async {
      emit(BovinoLoading());
      try {
        final result = await repository.analizarFrame(event.imagePath);
        emit(BovinoSuccess(result));
      } catch (e) {
        emit(BovinoFailure(e.toString()));
      }
    });
  }
}
