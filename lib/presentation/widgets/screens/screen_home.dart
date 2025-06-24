import 'package:flutter/material.dart';

// Organisms
import '../organisms/app_bar_organism.dart';
import '../organisms/home_content_organism.dart';
import '../organisms/camera_view_organism.dart';
import '../organisms/settings_view_organism.dart';
import '../organisms/bottom_navigation_organism.dart';

/// Screen para la página de inicio
/// Sigue Atomic Design y las reglas de desarrollo establecidas
/// Maneja la estructura general y la navegación entre vistas
class ScreenHome extends StatelessWidget {
  final int currentIndex;
  final String? selectedBreed;
  final Function(String)? onBreedSelected;
  final Function(int)? onNavigationTap;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onSettingsPressed;

  const ScreenHome({
    super.key,
    required this.currentIndex,
    this.selectedBreed,
    this.onBreedSelected,
    this.onNavigationTap,
    this.onCameraPressed,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarOrganism(),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationOrganism(
        currentIndex: currentIndex,
        onTap: onNavigationTap ?? (_) {},
      ),
    );
  }

  Widget _buildBody() {
    switch (currentIndex) {
      case 0:
        return HomeContentOrganism(
          selectedBreed: selectedBreed,
          onBreedSelected: onBreedSelected,
          onCameraPressed: onCameraPressed,
          onSettingsPressed: onSettingsPressed,
        );
      case 1:
        return CameraViewOrganism(onCameraPressed: onCameraPressed);
      case 2:
        return SettingsViewOrganism(onSettingsPressed: onSettingsPressed);
      default:
        return HomeContentOrganism(
          selectedBreed: selectedBreed,
          onBreedSelected: onBreedSelected,
          onCameraPressed: onCameraPressed,
          onSettingsPressed: onSettingsPressed,
        );
    }
  }
}
