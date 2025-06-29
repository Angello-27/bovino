import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';

// BLoCs
import '../blocs/theme_bloc.dart';
import '../blocs/connectivity_bloc.dart';

// Atoms
import '../widgets/atoms/custom_text.dart';
import '../widgets/atoms/custom_button.dart';

/// Página principal simplificada de la aplicación
/// Solo contiene elementos esenciales: AppBar, imagen, mensaje de conexión y botón de cámara
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ThemeBloc _themeBloc;
  late ConnectivityBloc _connectivityBloc;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
  }

  void _initializeBlocs() {
    try {
      // Intentar obtener BLoCs desde GetIt
      if (GetIt.instance.isRegistered<ThemeBloc>()) {
        _themeBloc = GetIt.instance<ThemeBloc>();
        _logger.i('✅ ThemeBloc obtenido desde GetIt en HomePage');
      } else {
        _themeBloc = ThemeBloc();
        _logger.w('⚠️ ThemeBloc no registrado en GetIt, creando manualmente en HomePage');
      }

      if (GetIt.instance.isRegistered<ConnectivityBloc>()) {
        _connectivityBloc = GetIt.instance<ConnectivityBloc>();
        _logger.i('✅ ConnectivityBloc obtenido desde GetIt en HomePage');
      } else {
        _connectivityBloc = ConnectivityBloc();
        _logger.w('⚠️ ConnectivityBloc no registrado en GetIt, creando manualmente en HomePage');
      }
    } catch (e) {
      _logger.e('❌ Error al obtener BLoCs en HomePage: $e');
      _themeBloc = ThemeBloc();
      _connectivityBloc = ConnectivityBloc();
    }
  }

  @override
  void dispose() {
    _themeBloc.close();
    _connectivityBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>.value(value: _themeBloc),
        BlocProvider<ConnectivityBloc>.value(value: _connectivityBloc),
      ],
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const CustomText(
        text: 'Bovino IA',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 2,
      actions: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return IconButton(
              icon: Icon(
                state is ThemeLoaded && state.theme.brightness == Brightness.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () {
                _themeBloc.add(const ToggleThemeEvent());
              },
              tooltip: 'Cambiar tema',
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen de ganado bovino
            _buildBovinoImage(),
            const SizedBox(height: 32),
            
            // Mensaje de conexión
            _buildConnectionStatus(),
            const SizedBox(height: 48),
            
            // Botón para ir a la cámara
            _buildCameraButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildBovinoImage() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/bovino_main.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.pets,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: state is ConnectivityConnected 
                ? Colors.green.withValues(alpha: 0.1)
                : Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: state is ConnectivityConnected 
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                state is ConnectivityConnected 
                    ? Icons.wifi
                    : Icons.wifi_off,
                color: state is ConnectivityConnected 
                    ? Colors.green
                    : Colors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              CustomText(
                text: state is ConnectivityConnected 
                    ? 'Conectado al servidor'
                    : 'Desconectado del servidor',
                style: TextStyle(
                  color: state is ConnectivityConnected 
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraButton() {
    return CustomButton(
      text: 'Iniciar Análisis',
      onPressed: () {
        _logger.i('🚀 Navegando a página de cámara...');
        context.push('/camara');
      },
      backgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      borderRadius: 12,
    );
  }
}
