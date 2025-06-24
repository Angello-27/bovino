import 'package:flutter/material.dart';

// Atoms
import '../atoms/custom_text.dart';
import '../../../core/constants/app_colors.dart';

/// Widget molecular para mostrar el indicador de tema actual
class ThemeIndicator extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double? iconSize;
  final double? fontSize;

  const ThemeIndicator({
    super.key,
    this.margin,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: margin ?? const EdgeInsets.only(top: 16),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDark ? Icons.nightlight_round : Icons.wb_sunny,
            color: isDark ? AppColors.primary : AppColors.secondary,
            size: iconSize ?? 20,
          ),
          const SizedBox(width: 8),
          CaptionText(
            text: isDark ? 'Tema Oscuro' : 'Tema Claro',
            color: textColor ?? theme.colorScheme.onSurfaceVariant,
            fontSize: fontSize ?? 12,
          ),
        ],
      ),
    );
  }
}
