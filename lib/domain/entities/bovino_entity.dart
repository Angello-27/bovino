import 'package:equatable/equatable.dart';

class BovinoEntity extends Equatable {
  final String raza;
  final List<String> caracteristicas;
  final double confianza;
  final DateTime timestamp;
  final double pesoEstimado;

  const BovinoEntity({
    required this.raza,
    required this.caracteristicas,
    required this.confianza,
    required this.timestamp,
    required this.pesoEstimado,
  });

  @override
  List<Object?> get props => [
    raza,
    caracteristicas,
    confianza,
    timestamp,
    pesoEstimado,
  ];

  BovinoEntity copyWith({
    String? raza,
    List<String>? caracteristicas,
    double? confianza,
    DateTime? timestamp,
    double? pesoEstimado,
  }) {
    return BovinoEntity(
      raza: raza ?? this.raza,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      confianza: confianza ?? this.confianza,
      timestamp: timestamp ?? this.timestamp,
      pesoEstimado: pesoEstimado ?? this.pesoEstimado,
    );
  }

  bool get esAnalisisConfiable => confianza >= 0.7;
  String get confianzaFormateada => '${(confianza * 100).toStringAsFixed(1)}%';
  String get timestampFormateado =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

  String get pesoFormateado => '${pesoEstimado.toStringAsFixed(1)} kg';
  String get pesoEnLibras =>
      '${(pesoEstimado * 2.20462).toStringAsFixed(1)} lbs';
  bool get esPesoNormal => pesoEstimado >= 300 && pesoEstimado <= 800;
}
