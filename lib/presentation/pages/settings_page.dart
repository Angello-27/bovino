import 'package:flutter/material.dart';

// Core
import '../../core/constants/app_colors.dart';

// Atoms
import '../widgets/atoms/custom_text.dart';

// Molecules
import '../widgets/molecules/theme_toggle_button.dart';

/// Página de configuración
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText(text: 'Configuración'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.contentTextLight,
        elevation: 0,
        actions: const [ThemeToggleButton()],
      ),
      body: const Center(
        child: TitleText(
          text: 'Configuración - En desarrollo',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
