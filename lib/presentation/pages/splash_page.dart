import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_messages.dart';
// import '../../core/di/dependency_injection.dart';
import '../../core/routes/app_router.dart';
import '../../core/services/splash_service.dart';

// BLoCs
import '../blocs/splash_bloc.dart';

// Atoms
import '../widgets/atoms/custom_text.dart';

/// Página de splash screen
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late SplashBloc _splashBloc;
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSplashBloc();
    _startSplash();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  void _initializeSplashBloc() {
    try {
      // Intentar obtener el SplashBloc registrado en GetIt
      if (GetIt.instance.isRegistered<SplashBloc>()) {
        _splashBloc = GetIt.instance<SplashBloc>();
        _logger.i('✅ SplashBloc obtenido desde GetIt');
      } else {
        // Fallback: crear un SplashBloc manualmente
        _logger.w('⚠️ SplashBloc no registrado en GetIt, creando manualmente');
        if (GetIt.instance.isRegistered<SplashService>()) {
          final splashService = GetIt.instance<SplashService>();
          _splashBloc = SplashBloc(splashService: splashService);
        } else {
          // Último fallback: crear sin dependencias
          _logger.e('❌ SplashService no disponible, creando SplashBloc sin dependencias');
          _splashBloc = SplashBloc(splashService: SplashService());
        }
      }
    } catch (e) {
      _logger.e('❌ Error al inicializar SplashBloc: $e');
      // Fallback final
      _splashBloc = SplashBloc(splashService: SplashService());
    }
  }

  void _startSplash() {
    _splashBloc.add(const InitializeSplash());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashBloc>.value(
      value: _splashBloc,
      child: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashReady) {
            _navigateToHome();
          } else if (state is SplashError) {
            _handleError(state.failure);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.primary,
          body: _buildSplashContent(),
        ),
      ),
    );
  }

  Widget _buildSplashContent() {
    return BlocBuilder<SplashBloc, SplashState>(
      builder: (context, state) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animado
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.contentTextLight,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 30),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Título de la app
              FadeTransition(
                opacity: _fadeAnimation,
                child: const TitleText(
                  text: AppConstants.appName,
                  color: AppColors.contentTextLight,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              FadeTransition(
                opacity: _fadeAnimation,
                child: const BodyText(
                  text: AppConstants.appDescription,
                  color: AppColors.contentTextLight,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 60),

              // Indicador de estado
              _buildStatusIndicator(state),

              const SizedBox(height: 40),

              // Indicador de progreso
              if (state is SplashLoading || state is SplashCheckingServer)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.contentTextLight),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(SplashState state) {
    String message = AppMessages.ready;
    IconData icon = Icons.settings;

    if (state is SplashLoading) {
      message = state.message;
      icon = Icons.settings;
    } else if (state is SplashCheckingServer) {
      message = AppMessages.helpConnection;
      icon = Icons.cloud;
    } else if (state is SplashReady) {
      message =
          state.serverAvailable
              ? AppMessages.success
              : AppMessages.serverUnavailable;
      icon = state.serverAvailable ? Icons.cloud_done : Icons.cloud_off;
    } else if (state is SplashError) {
      message = AppMessages.error;
      icon = Icons.error;
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.contentTextLight, size: 20),
          const SizedBox(width: 8),
          CaptionText(text: message, color: AppColors.contentTextLight),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        AppRouter.goToHome(context);
      }
    });
  }

  void _handleError(dynamic failure) {
    // Aquí se puede manejar el error del splash
    // Por ejemplo, mostrar un diálogo o navegar a una página de error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: [31m${failure.message ?? failure.toString()}[0m'),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
