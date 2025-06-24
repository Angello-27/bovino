import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';

// Core
import '../../core/services/splash_service.dart';
import '../../core/errors/failures.dart';

// Events
abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSplash extends SplashEvent {
  const InitializeSplash();
}

// States
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {
  final String message;

  const SplashLoading({this.message = 'Iniciando aplicación...'});

  @override
  List<Object?> get props => [message];
}

class SplashCheckingServer extends SplashState {
  const SplashCheckingServer();
}

class SplashReady extends SplashState {
  final bool serverAvailable;

  const SplashReady({required this.serverAvailable});

  @override
  List<Object?> get props => [serverAvailable];
}

class SplashError extends SplashState {
  final Failure failure;

  const SplashError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

// BLoC
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SplashService _splashService;
  final Logger _logger = Logger();

  SplashBloc({required SplashService splashService})
    : _splashService = splashService,
      super(SplashInitial()) {
    on<InitializeSplash>(_onInitializeSplash);
  }

  Future<void> _onInitializeSplash(
    InitializeSplash event,
    Emitter<SplashState> emit,
  ) async {
    try {
      _logger.i('Iniciando proceso de splash...');

      emit(const SplashLoading());

      // Inicializar splash service
      await _splashService.initialize();

      emit(const SplashCheckingServer());

      // Verificar conexión al servidor
      final serverAvailable = await _splashService.checkServerConnection();

      emit(SplashReady(serverAvailable: serverAvailable));

      _logger.i(
        'Splash completado - Servidor: ${serverAvailable ? "Disponible" : "No disponible"}',
      );
    } catch (e) {
      _logger.e('Error en splash: $e');
      emit(SplashError(failure: UnknownFailure(message: e.toString())));
    }
  }
}
