import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovino IA'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _mostrarHistorial(context),
          ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () => _mostrarInformacion(context),
          ),
        ],
      ),
      body: const HomeView(),
    );
  }

  void _mostrarHistorial(BuildContext context) {
    // TODO: Implementar navegación al historial
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Historial - En desarrollo')));
  }

  void _mostrarInformacion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Acerca de Bovino IA'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bovino IA es una aplicación que utiliza inteligencia artificial para:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('• Identificar razas de ganado bovino'),
                Text('• Estimar el peso del animal'),
                Text('• Proporcionar características detalladas'),
                Text('• Mantener un historial de análisis'),
                SizedBox(height: 16),
                Text(
                  'Versión: 1.0.0',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header informativo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.camera_alt, size: 48, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text(
                    'Captura una imagen del ganado',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'La IA analizará la raza y estimará el peso',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Widget de cámara (placeholder)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 80, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cámara - En desarrollo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implementar captura de imagen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Funcionalidad en desarrollo'),
                        ),
                      );
                    },
                    child: const Text('Simular Análisis'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
