import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/bovino_entity.dart';

part 'bovino_model.g.dart';

@JsonSerializable()
class BovinoModel extends Equatable {
  final String id;
  final String raza;
  final double pesoEstimado;
  final double confianza;
  final String descripcion;
  final List<String> caracteristicas;
  @JsonKey(name: 'fecha_analisis')
  final DateTime fechaAnalisis;
  @JsonKey(name: 'imagen_path')
  final String? imagenPath;

  const BovinoModel({
    required this.id,
    required this.raza,
    required this.pesoEstimado,
    required this.confianza,
    required this.descripcion,
    required this.caracteristicas,
    required this.fechaAnalisis,
    this.imagenPath,
  });

  factory BovinoModel.fromJson(Map<String, dynamic> json) =>
      _$BovinoModelFromJson(json);

  Map<String, dynamic> toJson() => _$BovinoModelToJson(this);

  // Convertir a entidad de dominio
  BovinoEntity toEntity() {
    return BovinoEntity(
      id: id,
      raza: raza,
      pesoEstimado: pesoEstimado,
      confianza: confianza,
      descripcion: descripcion,
      caracteristicas: caracteristicas,
      fechaAnalisis: fechaAnalisis,
      imagenPath: imagenPath,
    );
  }

  // Crear desde entidad de dominio
  factory BovinoModel.fromEntity(BovinoEntity entity) {
    return BovinoModel(
      id: entity.id,
      raza: entity.raza,
      pesoEstimado: entity.pesoEstimado,
      confianza: entity.confianza,
      descripcion: entity.descripcion,
      caracteristicas: entity.caracteristicas,
      fechaAnalisis: entity.fechaAnalisis,
      imagenPath: entity.imagenPath,
    );
  }

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

  BovinoModel copyWith({
    String? id,
    String? raza,
    double? pesoEstimado,
    double? confianza,
    String? descripcion,
    List<String>? caracteristicas,
    DateTime? fechaAnalisis,
    String? imagenPath,
  }) {
    return BovinoModel(
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
} 