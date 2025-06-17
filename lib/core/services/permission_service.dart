import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../errors/failures.dart';

/// Servicio para manejo de permisos siguiendo Clean Architecture
class PermissionService {
  /// Verifica y solicita permisos de cámara
  Future<PermissionResult> requestCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        return PermissionResult(
          isGranted: true,
          permission: Permission.camera,
          message: 'Permiso de cámara ya concedido',
        );
      }
      
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return _handlePermissionResult(result, Permission.camera);
      }
      
      if (status.isPermanentlyDenied) {
        return PermissionResult(
          isGranted: false,
          permission: Permission.camera,
          message: 'Permiso de cámara denegado permanentemente. Ve a Configuración > Aplicaciones > Bovino IA > Permisos',
          requiresSettings: true,
        );
      }
      
      return PermissionResult(
        isGranted: false,
        permission: Permission.camera,
        message: 'Estado de permiso desconocido: $status',
      );
    } catch (e) {
      return PermissionResult(
        isGranted: false,
        permission: Permission.camera,
        message: 'Error al solicitar permiso de cámara: $e',
      );
    }
  }

  /// Verifica y solicita permisos de almacenamiento según la versión de Android
  Future<PermissionResult> requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
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
      } else {
        // iOS
        return await _requestIOSStoragePermission();
      }
    } catch (e) {
      return PermissionResult(
        isGranted: false,
        permission: null,
        message: 'Error al solicitar permisos de almacenamiento: $e',
      );
    }
  }

  /// Solicita permisos de medios para Android 13+
  Future<PermissionResult> _requestMediaPermissions() async {
    final photosStatus = await Permission.photos.status;
    final videosStatus = await Permission.videos.status;
    
    if (photosStatus.isGranted && videosStatus.isGranted) {
      return PermissionResult(
        isGranted: true,
        permission: Permission.photos,
        message: 'Permisos de medios ya concedidos',
      );
    }
    
    // Solicitar permisos de fotos y videos
    final photosResult = await Permission.photos.request();
    final videosResult = await Permission.videos.request();
    
    if (photosResult.isGranted && videosResult.isGranted) {
      return PermissionResult(
        isGranted: true,
        permission: Permission.photos,
        message: 'Permisos de medios concedidos',
      );
    }
    
    return PermissionResult(
      isGranted: false,
      permission: Permission.photos,
      message: 'Permisos de medios denegados',
      requiresSettings: photosResult.isPermanentlyDenied || videosResult.isPermanentlyDenied,
    );
  }

  /// Solicita permisos de almacenamiento con scope para Android 10-12
  Future<PermissionResult> _requestScopedStoragePermission() async {
    final status = await Permission.storage.status;
    
    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        permission: Permission.storage,
        message: 'Permiso de almacenamiento ya concedido',
      );
    }
    
    final result = await Permission.storage.request();
    return _handlePermissionResult(result, Permission.storage);
  }

  /// Solicita permisos de almacenamiento legacy para Android 9-
  Future<PermissionResult> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.status;
    
    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        permission: Permission.storage,
        message: 'Permiso de almacenamiento ya concedido',
      );
    }
    
    final result = await Permission.storage.request();
    return _handlePermissionResult(result, Permission.storage);
  }

  /// Solicita permisos de almacenamiento para iOS
  Future<PermissionResult> _requestIOSStoragePermission() async {
    final status = await Permission.photos.status;
    
    if (status.isGranted) {
      return PermissionResult(
        isGranted: true,
        permission: Permission.photos,
        message: 'Permiso de fotos ya concedido',
      );
    }
    
    final result = await Permission.photos.request();
    return _handlePermissionResult(result, Permission.photos);
  }

  /// Maneja el resultado de una solicitud de permiso
  PermissionResult _handlePermissionResult(PermissionStatus status, Permission permission) {
    switch (status) {
      case PermissionStatus.granted:
        return PermissionResult(
          isGranted: true,
          permission: permission,
          message: 'Permiso concedido',
        );
      case PermissionStatus.denied:
        return PermissionResult(
          isGranted: false,
          permission: permission,
          message: 'Permiso denegado',
        );
      case PermissionStatus.permanentlyDenied:
        return PermissionResult(
          isGranted: false,
          permission: permission,
          message: 'Permiso denegado permanentemente. Ve a Configuración > Aplicaciones > Bovino IA > Permisos',
          requiresSettings: true,
        );
      case PermissionStatus.restricted:
        return PermissionResult(
          isGranted: false,
          permission: permission,
          message: 'Permiso restringido por políticas del sistema',
        );
      case PermissionStatus.limited:
        return PermissionResult(
          isGranted: true,
          permission: permission,
          message: 'Permiso concedido con limitaciones',
          isLimited: true,
        );
      case PermissionStatus.provisional:
        return PermissionResult(
          isGranted: true,
          permission: permission,
          message: 'Permiso concedido provisionalmente',
          isProvisional: true,
        );
      default:
        return PermissionResult(
          isGranted: false,
          permission: permission,
          message: 'Estado de permiso desconocido: $status',
        );
    }
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

  /// Obtiene el estado actual de todos los permisos
  Future<Map<Permission, PermissionStatus>> getPermissionStatuses() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.photos,
      Permission.videos,
    ];
    
    final statuses = <Permission, PermissionStatus>{};
    
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }
    
    return statuses;
  }
}

/// Resultado de una solicitud de permiso
class PermissionResult {
  final bool isGranted;
  final Permission? permission;
  final String message;
  final bool requiresSettings;
  final bool isLimited;
  final bool isProvisional;

  const PermissionResult({
    required this.isGranted,
    this.permission,
    required this.message,
    this.requiresSettings = false,
    this.isLimited = false,
    this.isProvisional = false,
  });

  @override
  String toString() {
    return 'PermissionResult(isGranted: $isGranted, permission: $permission, message: $message, requiresSettings: $requiresSettings)';
  }
} 