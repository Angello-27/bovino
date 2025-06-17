import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con logo
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.uiConfig['primaryColor']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(AppConstants.uiConfig['primaryColor']),
                    ),
                  ),
                  Text(
                    'Versión ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Descripción
            _buildSection(
              title: 'Descripción',
              icon: Icons.info,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bovino IA es una aplicación móvil que utiliza inteligencia artificial para analizar imágenes de ganado bovino y proporcionar información detallada sobre:',
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem('Identificación de razas'),
                  _buildFeatureItem('Estimación de peso'),
                  _buildFeatureItem('Análisis de características'),
                  _buildFeatureItem('Historial de análisis'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Características técnicas
            _buildSection(
              title: 'Características Técnicas',
              icon: Icons.engineering,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechItem('Arquitectura', 'Clean Architecture'),
                  _buildTechItem('Patrón de diseño', 'Atomic Design'),
                  _buildTechItem('Estado', 'Provider Pattern'),
                  _buildTechItem('Navegación', 'GoRouter'),
                  _buildTechItem('IA', 'OpenAI GPT-4 Vision'),
                  _buildTechItem('Almacenamiento', 'SharedPreferences'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tecnologías utilizadas
            _buildSection(
              title: 'Tecnologías',
              icon: Icons.code,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTechItem('Framework', 'Flutter'),
                  _buildTechItem('Lenguaje', 'Dart'),
                  _buildTechItem('HTTP Client', 'Dio'),
                  _buildTechItem('Cámara', 'Camera Plugin'),
                  _buildTechItem('Permisos', 'Permission Handler'),
                  _buildTechItem('UI', 'Material Design 3'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información de contacto
            _buildSection(
              title: 'Contacto',
              icon: Icons.contact_support,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContactItem(Icons.email, 'Email', 'support@bovinoia.com'),
                  _buildContactItem(Icons.web, 'Sitio web', 'www.bovinoia.com'),
                  _buildContactItem(Icons.phone, 'Teléfono', '+1 (555) 123-4567'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Licencia
            _buildSection(
              title: 'Licencia',
              icon: Icons.gavel,
              content: const Text(
                'Esta aplicación está licenciada bajo la Licencia MIT. Puedes usar, modificar y distribuir este software libremente.',
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de cerrar
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(AppConstants.uiConfig['primaryColor']),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildTechItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(AppConstants.uiConfig['primaryColor']),
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 