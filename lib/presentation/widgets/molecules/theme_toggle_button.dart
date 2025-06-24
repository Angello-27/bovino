import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import '../../../core/constants/app_colors.dart';

// Presentation
import '../../blocs/theme_bloc.dart';

/// Widget molecular para el botón de cambio de tema
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class ThemeToggleButton extends StatelessWidget {
  final double? size;
  final Color? iconColor;
  final String? tooltip;

  const ThemeToggleButton({super.key, this.size, this.iconColor, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark = state is ThemeLoaded ? state.isDark : false;
        final currentIconColor = iconColor ?? Theme.of(context).iconTheme.color;
        final currentSize = size ?? 24.0;
        final currentTooltip =
            tooltip ??
            (isDark ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro');

        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            size: currentSize,
            color: currentIconColor,
          ),
          tooltip: currentTooltip,
          onPressed: () {
            context.read<ThemeBloc>().add(const ToggleThemeEvent());
          },
        );
      },
    );
  }
}

/// Widget molecular para mostrar información del tema
class ThemeInfoCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? borderColor;
  final double? borderWidth;

  const ThemeInfoCard({
    super.key,
    this.margin,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is ThemeLoaded) {
          final currentMargin = margin ?? const EdgeInsets.all(16);
          final currentPadding = padding ?? const EdgeInsets.all(16);
          final currentBorderRadius = borderRadius ?? 12.0;
          final currentBorderColor =
              borderColor ?? Theme.of(context).colorScheme.outline;
          final currentBorderWidth = borderWidth ?? 1.0;

          return Container(
            margin: currentMargin,
            padding: currentPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(currentBorderRadius),
              border: Border.all(
                color: currentBorderColor,
                width: currentBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      state.isDark ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Información del Tema',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Nombre', state.themeName),
                _buildInfoRow('Tipo', state.isDark ? 'Oscuro' : 'Claro'),
                _buildInfoRow('Brillo', state.isDark ? 'Bajo' : 'Alto'),
                _buildInfoRow('Contraste', state.isDark ? 'Alto' : 'Estándar'),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
