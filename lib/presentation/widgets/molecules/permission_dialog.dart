import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/permission_service.dart';
import '../atoms/custom_button.dart';
import '../../../core/constants/app_constants.dart';

class PermissionDialog extends StatefulWidget {
  final PermissionService permissionService;
  final VoidCallback? onPermissionsGranted;
  final VoidCallback? onPermissionsDenied;

  const PermissionDialog({
    super.key,
    required this.permissionService,
    this.onPermissionsGranted,
    this.onPermissionsDenied,
  });

  @override
  State<PermissionDialog> createState() => _PermissionDialogState();
}

class _PermissionDialogState extends State<PermissionDialog> {
  bool _isLoading = false;
  String _statusMessage = '';
  List<PermissionStatus> _permissionStatuses = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Verificando permisos...';
    });

    try {
      final statuses = await widget.permissionService.getPermissionStatuses();
      _permissionStatuses = statuses.values.toList();
      
      final allGranted = await widget.permissionService.checkAllPermissions();
      
      setState(() {
        _isLoading = false;
        _statusMessage = allGranted 
          ? 'Todos los permisos están concedidos'
          : 'Se requieren permisos para usar la cámara';
      });

      if (allGranted) {
        widget.onPermissionsGranted?.call();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error al verificar permisos: $e';
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Solicitando permisos...';
    });

    try {
      // Solicitar permisos de cámara
      final cameraResult = await widget.permissionService.requestCameraPermission();
      
      if (!cameraResult.isGranted) {
        setState(() {
          _isLoading = false;
          _statusMessage = cameraResult.message;
        });
        
        if (cameraResult.requiresSettings) {
          _showSettingsDialog();
        }
        return;
      }

      // Solicitar permisos de almacenamiento
      final storageResult = await widget.permissionService.requestStoragePermission();
      
      setState(() {
        _isLoading = false;
        _statusMessage = storageResult.message;
      });

      if (storageResult.isGranted) {
        widget.onPermissionsGranted?.call();
      } else if (storageResult.requiresSettings) {
        _showSettingsDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error al solicitar permisos: $e';
      });
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permisos Requeridos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings,
              size: 48,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Para usar la cámara y guardar imágenes, necesitas conceder permisos manualmente en la configuración del dispositivo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPermissionsDenied?.call();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.permissionService.openAppSettings();
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.camera_alt,
            color: const Color(AppConstants.uiConfig['primaryColor']),
          ),
          const SizedBox(width: 12),
          const Text('Permisos de Cámara'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono de estado
          Icon(
            _isLoading ? Icons.hourglass_empty : Icons.camera_alt,
            size: 64,
            color: _isLoading 
              ? Colors.grey 
              : const Color(AppConstants.uiConfig['primaryColor']),
          ),
          
          const SizedBox(height: 16),
          
          // Mensaje de estado
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          
          const SizedBox(height: 16),
          
          // Indicador de carga
          if (_isLoading)
            const CircularProgressIndicator(),
          
          const SizedBox(height: 16),
          
          // Información sobre permisos
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Esta aplicación necesita:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildPermissionItem(
                  Icons.camera_alt,
                  'Cámara',
                  'Para capturar imágenes del ganado',
                ),
                _buildPermissionItem(
                  Icons.photo_library,
                  'Almacenamiento',
                  'Para guardar las imágenes capturadas',
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.pop(context);
            widget.onPermissionsDenied?.call();
          },
          child: const Text('Cancelar'),
        ),
        CustomButton(
          onPressed: _isLoading ? null : _requestPermissions,
          text: _isLoading ? 'Solicitando...' : 'Conceder Permisos',
          icon: Icons.check,
          backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(AppConstants.uiConfig['primaryColor']),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 