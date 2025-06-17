import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bovino_provider.dart';
import '../widgets/organisms/camera_section.dart';
import '../widgets/molecules/analysis_result_card.dart';
import '../widgets/molecules/loading_overlay.dart';
import '../widgets/atoms/info_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovino IA'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
      body: Consumer<BovinoProvider>(
        builder: (context, provider, child) {
          return _buildBody(context, provider);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, BovinoProvider provider) {
    if (provider.isLoading) {
      return const LoadingOverlay(
        message: 'Analizando imagen del bovino...',
      );
    }

    if (provider.error != null) {
      return _buildErrorWidget(context, provider);
    }

    if (provider.bovinoAnalizado != null) {
      return AnalysisResultCard(
        bovino: provider.bovinoAnalizado!,
        onNuevoAnalisis: () => provider.limpiarAnalisis(),
        onVerHistorial: () => _mostrarHistorial(context),
      );
    }

    return _buildCameraWidget(context, provider);
  }

  Widget _buildCameraWidget(BuildContext context, BovinoProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header informativo
          InfoCard(
            icon: Icons.camera_alt,
            title: 'Captura una imagen del ganado',
            subtitle: 'La IA analizará la raza y estimará el peso',
            gradient: const LinearGradient(
              colors: [Colors.green, Colors.lightGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Widget de cámara
          Expanded(
            child: CameraSection(
              onImageCaptured: (imagenPath) => provider.analizarImagen(imagenPath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, BovinoProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.error?.message ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => provider.limpiarError(),
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarHistorial(BuildContext context) {
    Navigator.pushNamed(context, '/historial');
  }

  void _mostrarInformacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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