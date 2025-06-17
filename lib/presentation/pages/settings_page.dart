import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  double _imageQuality = 0.8;
  int _maxHistorialSize = 100;
  String _selectedTheme = 'Claro';

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDark = AppTheme.isDarkTheme(currentTheme);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Apariencia',
            icon: Icons.palette,
            children: [
              // Selector de tema
              ListTile(
                title: const Text('Tema de la aplicación'),
                subtitle: Text('Tema actual: $_selectedTheme'),
                leading: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: currentTheme.colorScheme.primary,
                ),
                trailing: DropdownButton<String>(
                  value: _selectedTheme,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedTheme = newValue;
                      });
                      _showThemeChangeDialog(newValue);
                    }
                  },
                  items: AppTheme.availableThemes.map<DropdownMenuItem<String>>((theme) {
                    return DropdownMenuItem<String>(
                      value: theme['name'] as String,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(theme['icon'] as IconData),
                          const SizedBox(width: 8),
                          Text(theme['name'] as String),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Modo oscuro automático
              SwitchListTile(
                title: const Text('Modo oscuro automático'),
                subtitle: const Text('Cambiar automáticamente según el sistema'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
              ),
              
              // Vista previa de colores
              _buildColorPreview(currentTheme),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Notificaciones',
            icon: Icons.notifications,
            children: [
              SwitchListTile(
                title: const Text('Notificaciones'),
                subtitle: const Text('Recibir notificaciones de análisis completados'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Calidad de imagen',
            icon: Icons.image,
            children: [
              ListTile(
                title: const Text('Calidad de imagen'),
                subtitle: Text('${(_imageQuality * 100).toInt()}%'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: _imageQuality,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: '${(_imageQuality * 100).toInt()}%',
                    onChanged: (value) {
                      setState(() {
                        _imageQuality = value;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Almacenamiento',
            icon: Icons.storage,
            children: [
              ListTile(
                title: const Text('Tamaño máximo del historial'),
                subtitle: Text('$_maxHistorialSize análisis'),
                trailing: SizedBox(
                  width: 200,
                  child: Slider(
                    value: _maxHistorialSize.toDouble(),
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: _maxHistorialSize.toString(),
                    onChanged: (value) {
                      setState(() {
                        _maxHistorialSize = value.toInt();
                      });
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Limpiar caché'),
                subtitle: const Text('Eliminar archivos temporales'),
                leading: const Icon(Icons.cleaning_services),
                onTap: _showClearCacheDialog,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSection(
            title: 'Información',
            icon: Icons.info,
            children: [
              ListTile(
                title: const Text('Versión de la aplicación'),
                subtitle: Text(AppConstants.appVersion),
                leading: const Icon(Icons.app_settings_alt),
              ),
              ListTile(
                title: const Text('Acerca de'),
                subtitle: const Text('Información sobre la aplicación'),
                leading: const Icon(Icons.help),
                onTap: () => Navigator.pushNamed(context, '/about'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(AppConstants.uiConfig['primaryColor'])),
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
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildColorPreview(ThemeData theme) {
    final statusColors = AppTheme.getStatusColors(theme);
    final accentColors = AppTheme.getAccentColors(theme);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Colores del tema',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // Colores de estado
          const Text('Colores de estado:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: statusColors.entries.map((entry) {
              return _buildColorChip(entry.key, entry.value);
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // Colores de acento
          const Text('Colores de acento:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: accentColors.take(6).map((color) {
              return _buildColorChip('Acento', color);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.getAppropriateTextColor(color),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showThemeChangeDialog(String themeName) {
    final themeInfo = AppTheme.getThemeInfo(themeName);
    if (themeInfo == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cambiar a tema ${themeInfo['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(themeInfo['icon'] as IconData),
                const SizedBox(width: 8),
                Text(themeInfo['name'] as String),
              ],
            ),
            const SizedBox(height: 8),
            Text(themeInfo['description'] as String),
            const SizedBox(height: 16),
            const Text(
              '¿Deseas cambiar al tema ${themeInfo['name']}?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _changeTheme(themeName);
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }

  void _changeTheme(String themeName) {
    // Aquí implementarías la lógica para cambiar el tema
    // Por ejemplo, usando un provider o guardando en SharedPreferences
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tema cambiado a $themeName'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpiar caché'),
        content: const Text('¿Estás seguro de que quieres eliminar todos los archivos temporales?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearCache();
            },
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _clearCache() {
    // Aquí implementarías la lógica para limpiar el caché
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Caché limpiado correctamente'),
        backgroundColor: AppTheme.getStatusColors(Theme.of(context))['success'],
      ),
    );
  }
} 