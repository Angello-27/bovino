import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Core
import '../constants/app_messages.dart';

/// Servicio para manejo de permisos siguiendo Clean Architecture
class PermissionService {
  /// Verifica y solicita permisos de cámara
  Future<PermissionResult> requestCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.cameraPermissionGranted,
      );
    }
    final result = await Permission.camera.request();
    if (result.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.cameraPermissionGranted,
      );
    }
    return PermissionResult(
      isGranted: false,
      message: AppMessages.cameraPermissionDenied,
    );
  }

  /// Verifica y solicita permisos de almacenamiento según la versión de Android
  Future<PermissionResult> requestStoragePermission() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Android 13+ (API 33+)
    if (sdkInt >= 33) {
      return await _requestMediaPermissions();
    }
    // Android 10-12 (API 29-32)
    else if (sdkInt >= 29) {
      return await _requestScopedStoragePermission();
    }
    // Android 9 y anteriores (API 28-)
    else {
      return await _requestLegacyStoragePermission();
    }
  }

  /// Solicita permisos de medios para Android 13+
  Future<PermissionResult> _requestMediaPermissions() async {
    final photosStatus = await Permission.photos.status;
    final videosStatus = await Permission.videos.status;

    if (photosStatus.isGranted && videosStatus.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.mediaPermissionsAlreadyGranted,
      );
    }

    // Solicitar permisos de fotos y videos
    final photosResult = await Permission.photos.request();
    final videosResult = await Permission.videos.request();

    if (photosResult.isGranted && videosResult.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.mediaPermissionsGranted,
      );
    }

    return PermissionResult(
      isGranted: false,
      message: AppMessages.mediaPermissionsDenied,
    );
  }

  /// Solicita permisos de almacenamiento con scope para Android 10-12
  Future<PermissionResult> _requestScopedStoragePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.storagePermissionAlreadyGranted,
      );
    }

    final result = await Permission.storage.request();
    if (result.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.storagePermissionGranted,
      );
    }
    return PermissionResult(
      isGranted: false,
      message: AppMessages.storagePermissionDenied,
    );
  }

  /// Solicita permisos de almacenamiento legacy para Android 9-
  Future<PermissionResult> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.storagePermissionAlreadyGranted,
      );
    }

    final result = await Permission.storage.request();
    if (result.isGranted) {
      return PermissionResult(
        isGranted: true,
        message: AppMessages.storagePermissionGranted,
      );
    }
    return PermissionResult(
      isGranted: false,
      message: AppMessages.storagePermissionDenied,
    );
  }

  /// Verifica si todos los permisos necesarios están concedidos
  Future<bool> checkAllPermissions() async {
    final cameraResult = await requestCameraPermission();
    final storageResult = await requestStoragePermission();

    return cameraResult.isGranted && storageResult.isGranted;
  }

  /// Abre la configuración de la aplicación
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}

/// Resultado de una solicitud de permiso
class PermissionResult {
  final bool isGranted;
  final String message;
  const PermissionResult({required this.isGranted, required this.message});
}
