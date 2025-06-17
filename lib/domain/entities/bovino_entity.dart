import 'package:equatable/equatable.dart';

class BovinoEntity extends Equatable {
  final String id;
  final String raza;
  final double pesoEstimado;
  final double confianza;
  final String descripcion;
  final List<String> caracteristicas;
  final DateTime fechaAnalisis;
  final String? imagenPath;

  const BovinoEntity({
    required this.id,
    required this.raza,
    required this.pesoEstimado,
    required this.confianza,
    required this.descripcion,
    required this.caracteristicas,
    required this.fechaAnalisis,
    this.imagenPath,
  });

  @override
  List<Object?> get props => [
        id,
        raza,
        pesoEstimado,
        confianza,
        descripcion,
        caracteristicas,
        fechaAnalisis,
        imagenPath,
      ];

  BovinoEntity copyWith({
    String? id,
    String? raza,
    double? pesoEstimado,
    double? confianza,
    String? descripcion,
    List<String>? caracteristicas,
    DateTime? fechaAnalisis,
    String? imagenPath,
  }) {
    return BovinoEntity(
      id: id ?? this.id,
      raza: raza ?? this.raza,
      pesoEstimado: pesoEstimado ?? this.pesoEstimado,
      confianza: confianza ?? this.confianza,
      descripcion: descripcion ?? this.descripcion,
      caracteristicas: caracteristicas ?? this.caracteristicas,
      fechaAnalisis: fechaAnalisis ?? this.fechaAnalisis,
      imagenPath: imagenPath ?? this.imagenPath,
    );
  }

  bool get esAnalisisConfiable => confianza >= 0.7;
  bool get esPesoValido => pesoEstimado >= 50 && pesoEstimado <= 1500;
  String get pesoFormateado => '${pesoEstimado.toStringAsFixed(1)} kg';
  String get confianzaFormateada => '${(confianza * 100).toStringAsFixed(1)}%';
} 