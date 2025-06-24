import 'package:equatable/equatable.dart';

class BovinoEntity extends Equatable {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;

  const BovinoEntity({
    required this.raza,
    required this.caracteristicas,
    required this.confianza,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [raza, caracteristicas, confianza, timestamp];

  BovinoEntity copyWith({
    String? raza,
    List<String>? caracteristicas,
    double? confianza,
    DateTime? timestamp,
  }) {
    return BovinoEntity(
      raza: raza ?? this.raza,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      confianza: confianza ?? this.confianza,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  bool get esAnalisisConfiable => confianza >= 0.7;
  String get confianzaFormateada => '${(confianza * 100).toStringAsFixed(1)}%';
  String get timestampFormateado =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
}
