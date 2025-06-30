import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

// Core
import '../../core/services/connectivity_service.dart';

/// Eventos del ConnectivityBloc
abstract class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para verificar conectividad
class CheckConnectivityEvent extends ConnectivityEvent {
  const CheckConnectivityEvent();
}

/// Evento para conectar al servidor
class ConnectToServerEvent extends ConnectivityEvent {
  const ConnectToServerEvent();
}

/// Evento para desconectar del servidor
class DisconnectFromServerEvent extends ConnectivityEvent {
  const DisconnectFromServerEvent();
}

/// Estados del ConnectivityBloc
abstract class ConnectivityState extends Equatable {
  const ConnectivityState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ConnectivityInitial extends ConnectivityState {}

/// Estado de carga
class ConnectivityLoading extends ConnectivityState {}

/// Estado conectado
class ConnectivityConnected extends ConnectivityState {
  final String message;

  const ConnectivityConnected({this.message = 'Conectado al servidor'});

  @override
  List<Object?> get props => [message];
}

/// Estado desconectado
class ConnectivityDisconnected extends ConnectivityState {
  final String message;

  const ConnectivityDisconnected({this.message = 'Desconectado del servidor'});

  @override
  List<Object?> get props => [message];
}

/// Estado de error
class ConnectivityError extends ConnectivityState {
  final String message;

  const ConnectivityError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// BLoC para manejar la conectividad con el servidor
class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  late ConnectivityService _connectivityService;
  final Logger _logger = Logger();

  ConnectivityBloc({ConnectivityService? connectivityService}) 
      : super(ConnectivityInitial()) {
    _initializeConnectivityService(connectivityService);
    on<CheckConnectivityEvent>(_onCheckConnectivity);
    on<ConnectToServerEvent>(_onConnectToServer);
    on<DisconnectFromServerEvent>(_onDisconnectFromServer);
  }

  void _initializeConnectivityService(ConnectivityService? connectivityService) {
    try {
      if (connectivityService != null) {
        _connectivityService = connectivityService;
      } else if (GetIt.instance.isRegistered<ConnectivityService>()) {
        _connectivityService = GetIt.instance<ConnectivityService>();
      } else if (GetIt.instance.isRegistered<Dio>()) {
        final dio = GetIt.instance<Dio>();
        _connectivityService = ConnectivityService(dio);
      } else {
        // Fallback: crear con Dio por defecto
        final dio = Dio();
        _connectivityService = ConnectivityService(dio);
      }
      _logger.i('✅ ConnectivityService inicializado correctamente');
    } catch (e) {
      _logger.e('❌ Error al inicializar ConnectivityService: $e');
      // Fallback final
      final dio = Dio();
      _connectivityService = ConnectivityService(dio);
    }
  }

  /// Maneja el evento de verificar conectividad
  Future<void> _onCheckConnectivity(
    CheckConnectivityEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      _logger.i('🔍 Verificando conectividad...');
      emit(ConnectivityLoading());

      final isConnected = await _connectivityService.checkServerHealth();
      
      if (isConnected) {
        _logger.i('✅ Servidor conectado');
        emit(const ConnectivityConnected());
      } else {
        _logger.w('❌ Servidor desconectado');
        emit(const ConnectivityDisconnected());
      }
    } catch (e) {
      _logger.e('❌ Error al verificar conectividad: $e');
      emit(ConnectivityError(message: 'Error al verificar conexión: $e'));
    }
  }

  /// Maneja el evento de conectar al servidor
  Future<void> _onConnectToServer(
    ConnectToServerEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      _logger.i('🔌 Conectando al servidor...');
      emit(ConnectivityLoading());

      final isConnected = await _connectivityService.reconnect();
      
      if (isConnected) {
        _logger.i('✅ Conectado exitosamente al servidor');
        emit(const ConnectivityConnected());
      } else {
        _logger.w('❌ No se pudo conectar al servidor');
        emit(const ConnectivityDisconnected());
      }
    } catch (e) {
      _logger.e('❌ Error al conectar al servidor: $e');
      emit(ConnectivityError(message: 'Error al conectar: $e'));
    }
  }

  /// Maneja el evento de desconectar del servidor
  Future<void> _onDisconnectFromServer(
    DisconnectFromServerEvent event,
    Emitter<ConnectivityState> emit,
  ) async {
    try {
      _logger.i('🔌 Desconectando del servidor...');
      emit(ConnectivityLoading());

      _connectivityService.dispose();
      
      _logger.i('✅ Desconectado del servidor');
      emit(const ConnectivityDisconnected());
    } catch (e) {
      _logger.e('❌ Error al desconectar del servidor: $e');
      emit(ConnectivityError(message: 'Error al desconectar: $e'));
    }
  }

  @override
  Future<void> close() {
    _logger.i('🔌 Cerrando ConnectivityBloc');
    return super.close();
  }
} 