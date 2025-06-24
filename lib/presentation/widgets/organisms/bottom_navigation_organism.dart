import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_messages.dart';

/// Organismo para la navegación inferior
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class BottomNavigationOrganism extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationOrganism({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
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
          label: AppMessages.settings,
        ),
      ],
    );
  }
}
