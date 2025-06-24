import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

// Molecules
import '../molecules/theme_toggle_button.dart';

// Atoms
import '../atoms/custom_text.dart';

/// Organismo para el AppBar principal
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class AppBarOrganism extends StatelessWidget implements PreferredSizeWidget {
  const AppBarOrganism({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const TitleText(
        text: AppConstants.appName,
        color: AppColors.contentTextLight,
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.contentTextLight,
      elevation: AppUIConfig.appBarElevation,
      actions: const [ThemeToggleButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
