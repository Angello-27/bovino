import 'package:flutter/material.dart';

// Core
import '../../core/constants/app_colors.dart';
import '../../core/routes/app_router.dart';

// Atoms
import '../widgets/atoms/custom_icon.dart';
import '../widgets/atoms/custom_text.dart';
import '../widgets/atoms/custom_button.dart';

// Molecules
import '../widgets/molecules/theme_toggle_button.dart';

/// Página para manejar rutas no encontradas (404)
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class NotFoundPage extends StatelessWidget {
  final String? invalidPath;

  const NotFoundPage({super.key, this.invalidPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TitleText(text: 'Error'),
        backgroundColor: Colors.red,
        foregroundColor: AppColors.contentTextLight,
        elevation: AppUIConfig.appBarElevation,
        leading: IconButton(
          icon: const CustomIcon(icon: Icons.arrow_back),
          onPressed: () => AppRouter.goToHome(context),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppUIConfig.padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CustomIcon(
                icon: Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: AppUIConfig.padding),
              const TitleText(
                text: 'Página no encontrada',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppUIConfig.margin),
              BodyText(
                text:
                    invalidPath != null
                        ? 'La ruta "$invalidPath" no existe'
                        : 'La página solicitada no existe',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppUIConfig.padding * 1.5),
              CustomButton(
                text: 'Volver al inicio',
                icon: Icons.home,
                onPressed: () => AppRouter.goToHome(context),
              ),
              const SizedBox(height: AppUIConfig.margin),
              CustomTextButton(
                text: 'Volver atrás',
                icon: Icons.arrow_back,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
