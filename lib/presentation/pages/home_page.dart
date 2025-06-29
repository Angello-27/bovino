import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_ui_config.dart';
import '../../core/constants/app_messages.dart';

// BLoCs
import '../blocs/theme_bloc.dart';
import '../blocs/connectivity_bloc.dart';

// Atoms
import '../widgets/atoms/custom_text.dart';
import '../widgets/atoms/custom_button.dart';

/// Página principal atractiva de la aplicación Bovino IA
/// Diseño moderno con gradientes, animaciones y elementos interactivos
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late ThemeBloc _themeBloc;
  late ConnectivityBloc _connectivityBloc;
  final Logger _logger = Logger();

  // Animaciones
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeBlocs();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Controlador de fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controlador de escala
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Controlador de slide
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animaciones - inicializar inmediatamente
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
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

      // Verificar conectividad automáticamente
      _connectivityBloc.add(const CheckConnectivityEvent());
    } catch (e) {
      _logger.e('❌ Error al obtener BLoCs en HomePage: $e');
      _themeBloc = ThemeBloc();
      _connectivityBloc = ConnectivityBloc();
      // Intentar verificar conectividad incluso con fallback
      _connectivityBloc.add(const CheckConnectivityEvent());
    }
  }

  void _startAnimations() {
    // Asegurarse de que el widget esté montado antes de iniciar animaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _scaleController.forward();
        });
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _slideController.forward();
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
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
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
            AppColors.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header con AppBar personalizado
            _buildHeader(),
            
            // Contenido principal
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppUIConfig.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo y título
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const TitleText(
                  text: AppConstants.appName,
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
          
          // Botón de tema
          FadeTransition(
            opacity: _fadeAnimation,
            child: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: Icon(
                      state is ThemeLoaded && state.theme.brightness == Brightness.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      _themeBloc.add(const ToggleThemeEvent());
                    },
                    tooltip: AppMessages.changeTheme,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppUIConfig.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo principal animado
                _buildMainLogo(),
                const SizedBox(height: 30),
                
                // Título principal
                _buildMainTitle(),
                const SizedBox(height: 12),
                
                // Descripción
                _buildDescription(),
                const SizedBox(height: 40),
                
                // Estado de conexión
                _buildConnectionStatus(),
                const SizedBox(height: 30),
                
                // Botón principal
                _buildMainButton(),
                const SizedBox(height: 25),
                
                // Características
                _buildFeatures(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainLogo() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 80,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainTitle() {
    return const TitleText(
      text: AppMessages.intelligentAnalysis,
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return const BodyText(
      text: AppConstants.appDescription,
      color: Colors.white,
      fontSize: 16,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildConnectionStatus() {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: state is ConnectivityConnected 
                ? Colors.green.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: state is ConnectivityConnected 
                  ? Colors.green.withValues(alpha: 0.5)
                  : Colors.red.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: state is ConnectivityConnected 
                      ? Colors.green
                      : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  state is ConnectivityConnected 
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              CustomText(
                text: state is ConnectivityConnected 
                    ? AppMessages.success
                    : AppMessages.serverUnavailable,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainButton() {
    return CustomButton(
      text: AppMessages.startAnalysis,
      onPressed: () {
        _logger.i('🚀 Navegando a página de cámara...');
        context.push('/camara');
      },
      backgroundColor: Colors.white,
      textColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
      borderRadius: 25,
      icon: Icons.camera_alt,
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const CustomText(
          text: AppMessages.mainFeatures,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFeatureCard(
              icon: Icons.camera_alt,
              title: AppMessages.liveCamera,
              description: AppMessages.autoCapture,
            ),
            _buildFeatureCard(
              icon: Icons.psychology,
              title: AppMessages.advancedAI,
              description: AppMessages.tensorFlow,
            ),
            _buildFeatureCard(
              icon: Icons.analytics,
              title: AppMessages.fastAnalysis,
              description: AppMessages.instantResults,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 8),
          CustomText(
            text: title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          CustomText(
            text: description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
