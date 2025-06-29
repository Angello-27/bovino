import '../../domain/entities/bovino_entity.dart';
import '../../core/constants/app_messages.dart';
import '../../core/errors/failures.dart';

class BovinoModel {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;
  final double pesoEstimado;

  BovinoModel({
    required this.raza,
    required this.caracteristicas,
    required this.confianza,
    required this.timestamp,
    required this.pesoEstimado,
  });

  factory BovinoModel.fromJson(Map<String, dynamic> json) {
    // Validar que los campos requeridos existen
    final razaValue = json['raza'];
    if (razaValue == null) {
      throw const ValidationFailure(
        message: '${AppMessages.requiredFieldError}: raza',
        code: 'MISSING_RAZA_FIELD',
      );
    }

    return BovinoModel(
      raza: razaValue.toString(),
      caracteristicas: List<String>.from(json['caracteristicas'] ?? []),
      confianza: (json['confianza'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      pesoEstimado: (json['peso_estimado'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raza': raza,
      'caracteristicas': caracteristicas,
      'confianza': confianza,
      'timestamp': timestamp.toIso8601String(),
      'peso_estimado': pesoEstimado,
    };
  }

  BovinoEntity toEntity() {
    return BovinoEntity(
      raza: raza,
      caracteristicas: caracteristicas,
      confianza: confianza,
      timestamp: timestamp,
      pesoEstimado: pesoEstimado,
    );
  }

  factory BovinoModel.fromEntity(BovinoEntity entity) {
    return BovinoModel(
      raza: entity.raza,
      caracteristicas: entity.caracteristicas,
      confianza: entity.confianza,
      timestamp: entity.timestamp,
      pesoEstimado: entity.pesoEstimado,
    );
  }
}
