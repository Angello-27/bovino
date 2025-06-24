import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/camera_service.dart';

// Eventos para CameraBloc
abstract class CameraEvent {}

class CameraStarted extends CameraEvent {}

class CameraStopped extends CameraEvent {}

// Estados para CameraBloc
abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraRunning extends CameraState {}

class CameraStoppedState extends CameraState {}

// Bloc para manejar la cámara
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraService cameraService;

  CameraBloc({required this.cameraService}) : super(CameraInitial()) {
    on<CameraStarted>((event, emit) async {
      // Lógica para iniciar cámara
      emit(CameraRunning());
    });
    on<CameraStopped>((event, emit) async {
      // Lógica para detener cámara
      emit(CameraStoppedState());
    });
  }
}
