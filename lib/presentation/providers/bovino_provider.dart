import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/bovino_entity.dart';
import '../../domain/usecases/analizar_imagen_usecase.dart';
import '../../domain/usecases/obtener_historial_usecase.dart';
import '../../domain/usecases/eliminar_analisis_usecase.dart';
import '../../domain/usecases/limpiar_historial_usecase.dart';
import '../../core/errors/failures.dart';

class BovinoProvider extends ChangeNotifier {
  final AnalizarImagenUseCase _analizarImagenUseCase;
  final ObtenerHistorialUseCase _obtenerHistorialUseCase;
  final EliminarAnalisisUseCase _eliminarAnalisisUseCase;
  final LimpiarHistorialUseCase _limpiarHistorialUseCase;

  BovinoProvider({
    required AnalizarImagenUseCase analizarImagenUseCase,
    required ObtenerHistorialUseCase obtenerHistorialUseCase,
    required EliminarAnalisisUseCase eliminarAnalisisUseCase,
    required LimpiarHistorialUseCase limpiarHistorialUseCase,
  })  : _analizarImagenUseCase = analizarImagenUseCase,
        _obtenerHistorialUseCase = obtenerHistorialUseCase,
        _eliminarAnalisisUseCase = eliminarAnalisisUseCase,
        _limpiarHistorialUseCase = limpiarHistorialUseCase;

  // Estado
  bool _isLoading = false;
  BovinoEntity? _bovinoAnalizado;
  Failure? _error;
  List<BovinoEntity> _historial = [];

  // Getters
  bool get isLoading => _isLoading;
  BovinoEntity? get bovinoAnalizado => _bovinoAnalizado;
  Failure? get error => _error;
  List<BovinoEntity> get historial => _historial;

  // Métodos
  Future<void> analizarImagen(String imagenPath) async {
    _setLoading(true);
    _clearError();

    final result = await _analizarImagenUseCase(imagenPath);
    
    result.fold(
      (failure) => _setError(failure),
      (bovino) => _setBovinoAnalizado(bovino),
    );

    _setLoading(false);
  }

  Future<void> cargarHistorial() async {
    _setLoading(true);
    _clearError();

    final result = await _obtenerHistorialUseCase();
    
    result.fold(
      (failure) => _setError(failure),
      (historial) => _setHistorial(historial),
    );

    _setLoading(false);
  }

  Future<void> eliminarAnalisis(String id) async {
    _clearError();

    final result = await _eliminarAnalisisUseCase(id);
    
    result.fold(
      (failure) => _setError(failure),
      (_) => _removerDelHistorial(id),
    );
  }

  Future<void> limpiarHistorial() async {
    _clearError();

    final result = await _limpiarHistorialUseCase();
    
    result.fold(
      (failure) => _setError(failure),
      (_) => _limpiarHistorialLocal(),
    );
  }

  void limpiarAnalisis() {
    _bovinoAnalizado = null;
    _clearError();
    notifyListeners();
  }

  void limpiarError() {
    _clearError();
    notifyListeners();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setBovinoAnalizado(BovinoEntity bovino) {
    _bovinoAnalizado = bovino;
    notifyListeners();
  }

  void _setError(Failure failure) {
    _error = failure;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setHistorial(List<BovinoEntity> historial) {
    _historial = historial;
    notifyListeners();
  }

  void _removerDelHistorial(String id) {
    _historial.removeWhere((bovino) => bovino.id == id);
    notifyListeners();
  }

  void _limpiarHistorialLocal() {
    _historial.clear();
    notifyListeners();
  }
} 