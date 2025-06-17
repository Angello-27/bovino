import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'models/bovino.dart';
import 'services/openai_service.dart';
import 'widgets/camera_widget.dart';
import 'widgets/resultado_analisis_widget.dart';

void main() {
  runApp(const BovinoApp());
}

class BovinoApp extends StatelessWidget {
  const BovinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bovino IA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const BovinoHomePage(),
    );
  }
}

class BovinoHomePage extends StatefulWidget {
  const BovinoHomePage({super.key});

  @override
  State<BovinoHomePage> createState() => _BovinoHomePageState();
}

class _BovinoHomePageState extends State<BovinoHomePage> {
  final OpenAIService _openAIService = OpenAIService();
  
  bool _isAnalyzing = false;
  Bovino? _resultadoAnalisis;
  String? _errorMessage;
  File? _imagenCapturada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bovino IA'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: _mostrarInformacion,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isAnalyzing) {
      return _buildAnalizandoWidget();
    }

    if (_resultadoAnalisis != null) {
      return ResultadoAnalisisWidget(
        bovino: _resultadoAnalisis!,
        onNuevoAnalisis: _iniciarNuevoAnalisis,
      );
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return _buildCameraWidget();
  }

  Widget _buildCameraWidget() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header informativo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Captura una imagen del ganado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'La IA analizará la raza y estimará el peso',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Widget de cámara
          Expanded(
            child: CameraWidget(
              onImageCaptured: _procesarImagen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalizandoWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitDoubleBounce(
            color: Colors.green,
            size: 80.0,
          ),
          const SizedBox(height: 32),
          const Text(
            'Analizando imagen...',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'La IA está procesando la imagen del bovino',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          if (_imagenCapturada != null)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _imagenCapturada!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
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
            const Text(
              'Error en el análisis',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Error desconocido',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _iniciarNuevoAnalisis,
              icon: const Icon(Icons.refresh),
              label: const Text('Intentar de nuevo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _procesarImagen(File imagen) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _imagenCapturada = imagen;
    });

    try {
      final resultado = await _openAIService.analizarImagenBovino(imagen);
      
      setState(() {
        _resultadoAnalisis = resultado;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  void _iniciarNuevoAnalisis() {
    setState(() {
      _resultadoAnalisis = null;
      _errorMessage = null;
      _imagenCapturada = null;
    });
  }

  void _mostrarInformacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acerca de Bovino IA'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta aplicación utiliza inteligencia artificial para:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Identificar razas de ganado bovino'),
            Text('• Estimar el peso del animal'),
            Text('• Proporcionar características físicas'),
            SizedBox(height: 16),
            Text(
              'Para obtener mejores resultados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('• Captura imágenes claras del animal'),
            Text('• Asegúrate de que el bovino esté completo en la imagen'),
            Text('• Usa buena iluminación'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
