import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';

/// Átomo para botones personalizados
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? AppColors.contentTextLight,
        padding: padding ?? AppUIConfig.buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppUIConfig.borderRadius,
          ),
        ),
        elevation: AppUIConfig.buttonElevation,
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : icon != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppUIConfig.iconSize),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
              : Text(text),
    );
  }
}

/// Átomo para botones de texto
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        padding: padding ?? AppUIConfig.textButtonPadding,
      ),
      child:
          icon != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppUIConfig.iconSize),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
              : Text(text),
    );
  }
}

/// Átomo para botones de acción flotante
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primary,
      foregroundColor: foregroundColor ?? AppColors.contentTextLight,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }
}
