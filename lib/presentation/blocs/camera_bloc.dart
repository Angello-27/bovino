import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

import '../../core/services/camera_service.dart';
import '../../core/errors/failures.dart';

// Eventos para CameraBloc
abstract class CameraEvent extends Equatable {
  const CameraEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CameraEvent {}

class StartCapture extends CameraEvent {}

class StopCapture extends CameraEvent {}

class DisposeCamera extends CameraEvent {}

// Estados para CameraBloc
abstract class CameraState extends Equatable {
  const CameraState();

  @override
  List<Object?> get props => [];
}

class CameraInitial extends CameraState {}

class CameraLoading extends CameraState {}

class CameraReady extends CameraState {}

class CameraCapturing extends CameraState {
  final String lastFramePath;

  const CameraCapturing(this.lastFramePath);

  @override
  List<Object?> get props => [lastFramePath];
}

class CameraError extends CameraState {
  final Failure failure;

  const CameraError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// Bloc para manejar la cámara
class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final CameraService cameraService;
  final Logger _logger = Logger();

  CameraBloc({required this.cameraService}) : super(CameraInitial()) {
    on<InitializeCamera>(_onInitializeCamera);
    on<StartCapture>(_onStartCapture);
    on<StopCapture>(_onStopCapture);
    on<DisposeCamera>(_onDisposeCamera);
  }

  Future<void> _onInitializeCamera(
    InitializeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      emit(CameraLoading());
      _logger.i('Inicializando cámara...');

      await cameraService.initialize();
      emit(CameraReady());
      _logger.i('Cámara inicializada correctamente');
    } catch (e) {
      _logger.e('Error al inicializar cámara: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onStartCapture(
    StartCapture event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Iniciando captura de frames...');

      cameraService.startFrameCapture();

      // Escuchar el stream de frames
      cameraService.frameStream.listen((framePath) {
        _logger.d('Frame capturado: $framePath');
        emit(CameraCapturing(framePath));
      });

      _logger.i('Captura de frames iniciada');
    } catch (e) {
      _logger.e('Error al iniciar captura: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onStopCapture(
    StopCapture event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Deteniendo captura de frames...');

      cameraService.stopFrameCapture();
      emit(CameraReady());

      _logger.i('Captura de frames detenida');
    } catch (e) {
      _logger.e('Error al detener captura: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }

  Future<void> _onDisposeCamera(
    DisposeCamera event,
    Emitter<CameraState> emit,
  ) async {
    try {
      _logger.i('Liberando recursos de cámara...');

      await cameraService.dispose();
      emit(CameraInitial());

      _logger.i('Recursos de cámara liberados');
    } catch (e) {
      _logger.e('Error al liberar recursos: $e');
      emit(CameraError(UnknownFailure(message: e.toString())));
    }
  }
}
