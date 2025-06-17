import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class CameraFailure extends Failure {
  const CameraFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class StorageFailure extends Failure {
  const StorageFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class PermissionFailure extends Failure {
  const PermissionFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class AnalysisFailure extends Failure {
  const AnalysisFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    required String message,
    String? code,
  }) : super(message: message, code: code);
} 