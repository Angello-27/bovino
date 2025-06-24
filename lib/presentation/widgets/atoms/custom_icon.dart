import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';

/// Átomo para iconos personalizados
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class CustomIcon extends StatelessWidget {
  final IconData icon;
  final double? size;
  final Color? color;
  final String? tooltip;

  const CustomIcon({
    super.key,
    required this.icon,
    this.size,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: size ?? AppUIConfig.iconSize,
      color: color ?? Theme.of(context).iconTheme.color,
    );
  }
}

/// Átomo para iconos de estado
class StatusIcon extends StatelessWidget {
  final String status; // 'success', 'error', 'warning', 'info'
  final double? size;

  const StatusIcon({super.key, required this.status, this.size});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (status.toLowerCase()) {
      case 'success':
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case 'error':
        iconData = Icons.error;
        iconColor = AppColors.error;
        break;
      case 'warning':
        iconData = Icons.warning;
        iconColor = AppColors.warning;
        break;
      case 'info':
        iconData = Icons.info;
        iconColor = AppColors.info;
        break;
      default:
        iconData = Icons.help;
        iconColor = AppColors.lightGrey;
    }

    return CustomIcon(icon: iconData, size: size, color: iconColor);
  }
}
