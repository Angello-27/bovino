import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/bovino_model.dart';
import '../../../core/errors/failures.dart';

abstract class LocalDataSource {
  Future<void> guardarAnalisis(BovinoModel bovino);
  Future<List<BovinoModel>> obtenerHistorial();
  Future<void> eliminarAnalisis(String id);
  Future<void> limpiarHistorial();
}

class LocalDataSourceImpl implements LocalDataSource {
  static const String _historialKey = 'bovino_historial';
  static const int _maxHistorialSize = 100;

  @override
  Future<void> guardarAnalisis(BovinoModel bovino) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historialJson = prefs.getStringList(_historialKey) ?? [];
      
      // Agregar nuevo análisis al inicio
      historialJson.insert(0, jsonEncode(bovino.toJson()));
      
      // Mantener solo los últimos análisis
      if (historialJson.length > _maxHistorialSize) {
        historialJson.removeRange(_maxHistorialSize, historialJson.length);
      }
      
      await prefs.setStringList(_historialKey, historialJson);
    } catch (e) {
      throw StorageFailure(
        message: 'Error al guardar análisis: $e',
        code: 'SAVE_ERROR',
      );
    }
  }

  @override
  Future<List<BovinoModel>> obtenerHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historialJson = prefs.getStringList(_historialKey) ?? [];
      
      final historial = historialJson
          .map((json) => BovinoModel.fromJson(jsonDecode(json)))
          .toList();
      
      return historial;
    } catch (e) {
      throw StorageFailure(
        message: 'Error al obtener historial: $e',
        code: 'READ_ERROR',
      );
    }
  }

  @override
  Future<void> eliminarAnalisis(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historialJson = prefs.getStringList(_historialKey) ?? [];
      
      // Encontrar y eliminar el análisis por ID
      historialJson.removeWhere((json) {
        final bovino = BovinoModel.fromJson(jsonDecode(json));
        return bovino.id == id;
      });
      
      await prefs.setStringList(_historialKey, historialJson);
    } catch (e) {
      throw StorageFailure(
        message: 'Error al eliminar análisis: $e',
        code: 'DELETE_ERROR',
      );
    }
  }

  @override
  Future<void> limpiarHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historialKey);
    } catch (e) {
      throw StorageFailure(
        message: 'Error al limpiar historial: $e',
        code: 'CLEAR_ERROR',
      );
    }
  }
} 