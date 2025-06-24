import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_messages.dart';
import '../../core/routes/app_router.dart';

// Atoms
import '../widgets/atoms/custom_icon.dart';
import '../widgets/atoms/custom_text.dart';
import '../widgets/atoms/custom_button.dart';

// Molecules
import '../widgets/molecules/theme_toggle_button.dart';
import '../widgets/molecules/theme_indicator.dart';
import '../widgets/molecules/home_header.dart';
import '../widgets/molecules/breeds_list.dart';
import '../widgets/molecules/stats_card.dart';

// BLoCs
import '../blocs/theme_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _selectedBreed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText(
          text: AppConstants.appName,
          color: AppColors.contentTextLight,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
        elevation: AppUIConfig.appBarElevation,
        actions: const [ThemeToggleButton()],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeView();
      case 1:
        return const CameraView();
      case 2:
        return const SettingsView();
      default:
        return const HomeView();
    }
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.lightGrey600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Cámara'),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppUIConfig.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header principal
          const HomeHeader(),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Estadísticas
          const StatsRow(),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Lista de razas
          BreedsList(
            selectedBreed: null,
            onBreedSelected: (breed) {
              // Aquí se puede agregar lógica para mostrar detalles de la raza
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Raza seleccionada: $breed'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),

          const SizedBox(height: AppUIConfig.padding * 1.5),

          // Botones de acción
          _buildActionButtons(context),

          const SizedBox(height: AppUIConfig.padding),

          // Indicador de tema
          const ThemeIndicator(),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Iniciar Análisis con Cámara',
          icon: Icons.camera_alt,
          onPressed: () => AppRouter.goToCamera(context),
        ),
        const SizedBox(height: AppUIConfig.padding),
        CustomButton(
          text: 'Ver Configuración',
          icon: Icons.settings,
          backgroundColor: AppColors.secondary,
          onPressed: () => AppRouter.goToSettings(context),
        ),
      ],
    );
  }
}

class CameraView extends StatelessWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 80, color: AppColors.primary),
          const SizedBox(height: AppUIConfig.padding),
          const TitleText(
            text: 'Análisis con Cámara',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.margin),
          const BodyText(
            text: 'Usa la cámara para analizar ganado bovino en tiempo real',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.padding * 1.5),
          CustomButton(
            text: 'Iniciar Cámara',
            icon: Icons.camera_alt,
            onPressed: () => AppRouter.goToCamera(context),
          ),
        ],
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings, size: 80, color: AppColors.secondary),
          const SizedBox(height: AppUIConfig.padding),
          const TitleText(text: 'Configuración', textAlign: TextAlign.center),
          const SizedBox(height: AppUIConfig.margin),
          const BodyText(
            text: 'Configura los parámetros de la aplicación',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppUIConfig.padding * 1.5),
          CustomButton(
            text: 'Ir a Configuración',
            icon: Icons.settings,
            backgroundColor: AppColors.secondary,
            onPressed: () => AppRouter.goToSettings(context),
          ),
        ],
      ),
    );
  }
}
