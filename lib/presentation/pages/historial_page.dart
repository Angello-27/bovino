import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bovino_provider.dart';
import '../widgets/molecules/loading_overlay.dart';
import '../widgets/atoms/custom_button.dart';
import '../../core/constants/app_constants.dart';

class HistorialPage extends StatefulWidget {
  const HistorialPage({super.key});

  @override
  State<HistorialPage> createState() => _HistorialPageState();
}

class _HistorialPageState extends State<HistorialPage> {
  @override
  void initState() {
    super.initState();
    // Cargar historial al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BovinoProvider>().cargarHistorial();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Análisis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _showClearHistoryDialog,
            tooltip: 'Limpiar historial',
          ),
        ],
      ),
      body: Consumer<BovinoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingOverlay(
              message: 'Cargando historial...',
            );
          }

          if (provider.error != null) {
            return _buildErrorWidget(context, provider);
          }

          if (provider.historial.isEmpty) {
            return _buildEmptyWidget(context);
          }

          return _buildHistorialList(context, provider);
        },
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
              'Error al cargar historial',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
            CustomButton(
              onPressed: () => provider.cargarHistorial(),
              text: 'Reintentar',
              icon: Icons.refresh,
              backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay análisis en el historial',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Realiza tu primer análisis de ganado para ver el historial aquí',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            CustomButton(
              onPressed: () => Navigator.pop(context),
              text: 'Ir a Análisis',
              icon: Icons.camera_alt,
              backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialList(BuildContext context, BovinoProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.historial.length,
      itemBuilder: (context, index) {
        final bovino = provider.historial[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(AppConstants.uiConfig['primaryColor']),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              bovino.raza,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peso: ${bovino.pesoEstimado.toStringAsFixed(1)} kg'),
                Text('Confianza: ${(bovino.confianza * 100).toStringAsFixed(1)}%'),
                Text(
                  'Fecha: ${_formatDate(bovino.fechaAnalisis)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, bovino.id),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility),
                      SizedBox(width: 8),
                      Text('Ver detalles'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _showAnalysisDetails(bovino),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showAnalysisDetails(dynamic bovino) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Análisis - ${bovino.raza}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Raza: ${bovino.raza}'),
            Text('Peso estimado: ${bovino.pesoEstimado.toStringAsFixed(1)} kg'),
            Text('Confianza: ${(bovino.confianza * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(bovino.descripcion),
            const SizedBox(height: 8),
            const Text('Características:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...bovino.caracteristicas.map((caracteristica) => 
              Text('• $caracteristica')
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

  void _handleMenuAction(String action, String bovinoId) {
    switch (action) {
      case 'view':
        // Ver detalles (ya implementado en onTap)
        break;
      case 'delete':
        _showDeleteConfirmation(bovinoId);
        break;
    }
  }

  void _showDeleteConfirmation(String bovinoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar análisis'),
        content: const Text('¿Estás seguro de que quieres eliminar este análisis?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BovinoProvider>().eliminarAnalisis(bovinoId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Estás seguro de que quieres eliminar todo el historial?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BovinoProvider>().limpiarHistorial();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpiar todo'),
          ),
        ],
      ),
    );
  }
} 