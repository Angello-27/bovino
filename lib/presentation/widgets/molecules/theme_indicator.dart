import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Presentation
import '../../blocs/theme_bloc.dart';

// Atoms
import '../atoms/custom_icon.dart';
import '../atoms/custom_text.dart';

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
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is ThemeLoaded) {
          final currentMargin = margin ?? const EdgeInsets.only(top: 16);
          final currentPadding = padding ?? const EdgeInsets.all(8);
          final currentBorderRadius = borderRadius ?? 8.0;
          final currentBackgroundColor =
              backgroundColor ?? Theme.of(context).colorScheme.surfaceVariant;
          final currentTextColor =
              textColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
          final currentIconSize = iconSize ?? 16.0;
          final currentFontSize = fontSize ?? 12.0;

          return Container(
            padding: currentPadding,
            margin: currentMargin,
            decoration: BoxDecoration(
              color: currentBackgroundColor,
              borderRadius: BorderRadius.circular(currentBorderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIcon(
                  icon: state.isDark ? Icons.dark_mode : Icons.light_mode,
                  size: currentIconSize,
                  color: currentTextColor,
                ),
                const SizedBox(width: 8),
                CaptionText(
                  text: 'Tema: ${state.themeName}',
                  color: currentTextColor,
                  fontSize: currentFontSize,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
