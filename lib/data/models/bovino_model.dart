import '../../domain/entities/bovino_entity.dart';

class BovinoModel {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;

  BovinoModel({
    required this.raza,
    required this.caracteristicas,
    required this.confianza,
    required this.timestamp,
  });

  factory BovinoModel.fromJson(Map<String, dynamic> json) {
    return BovinoModel(
      raza: json['raza'] as String,
      caracteristicas: List<String>.from(json['caracteristicas'] ?? []),
      confianza: (json['confianza'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'raza': raza,
      'caracteristicas': caracteristicas,
      'confianza': confianza,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  BovinoEntity toEntity() {
    return BovinoEntity(
      raza: raza,
      caracteristicas: caracteristicas,
      confianza: confianza,
      timestamp: timestamp,
    );
  }

  factory BovinoModel.fromEntity(BovinoEntity entity) {
    return BovinoModel(
      raza: entity.raza,
      caracteristicas: entity.caracteristicas,
      confianza: entity.confianza,
      timestamp: entity.timestamp,
    );
  }
}
