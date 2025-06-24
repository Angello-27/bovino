import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_messages.dart';
import '../../../core/theme/theme_manager.dart';

// Presentation
import '../../blocs/theme_bloc.dart';

// Atoms
import '../atoms/custom_icon.dart';
import '../atoms/custom_text.dart';
import '../atoms/custom_button.dart';

/// Widget molecular para manejar errores de tema
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class ThemeErrorWidget extends StatelessWidget {
  final ThemeError errorState;
  final VoidCallback? onRetry;

  const ThemeErrorWidget({super.key, required this.errorState, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeManager.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppUIConfig.padding * 1.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const StatusIcon(status: 'error', size: 64),
                const SizedBox(height: AppUIConfig.padding),
                TitleText(text: AppMessages.error, textAlign: TextAlign.center),
                const SizedBox(height: AppUIConfig.margin),
                BodyText(
                  text: errorState.failure.message,
                  textAlign: TextAlign.center,
                  color: AppColors.lightGrey600,
                ),
                const SizedBox(height: AppUIConfig.padding * 1.5),
                CustomButton(
                  text: AppMessages.retry,
                  icon: Icons.refresh,
                  onPressed:
                      onRetry ??
                      () {
                        context.read<ThemeBloc>().add(
                          const InitializeThemeEvent(),
                        );
                      },
                ),
                const SizedBox(height: AppUIConfig.padding),
                CustomTextButton(
                  text: 'Usar tema claro',
                  icon: Icons.light_mode,
                  onPressed: () {
                    // Usar tema por defecto como fallback
                    context.read<ThemeBloc>().add(
                      const ChangeThemeEvent(isDark: false),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
