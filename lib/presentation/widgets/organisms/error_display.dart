import 'package:flutter/material.dart';

// Core
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_messages.dart';
import '../../../core/errors/failures.dart';

// Atoms
import '../atoms/custom_icon.dart';
import '../atoms/custom_text.dart';
import '../atoms/custom_button.dart';

/// Organismo para mostrar errores de manera consistente
/// Sigue Atomic Design y las reglas de desarrollo establecidas
class ErrorDisplay extends StatelessWidget {
  final Failure failure;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;
  final bool showDismissButton;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const ErrorDisplay({
    super.key,
    required this.failure,
    this.title,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = true,
    this.showDismissButton = false,
    this.padding,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppUIConfig.padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 77),
          width: AppUIConfig.borderWidth,
        ),
        boxShadow: AppUIConfig.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StatusIcon(status: 'error', size: 48),
          const SizedBox(height: AppUIConfig.padding),
          TitleText(
            text: title ?? AppMessages.error,
            textAlign: TextAlign.center,
            color: AppColors.error,
          ),
          const SizedBox(height: AppUIConfig.margin),
          BodyText(
            text: failure.message,
            textAlign: TextAlign.center,
            color: AppColors.lightGrey600,
          ),
          if (showRetryButton || showDismissButton) ...[
            const SizedBox(height: AppUIConfig.padding),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showRetryButton)
                  CustomButton(
                    text: AppMessages.retry,
                    icon: Icons.refresh,
                    onPressed: onRetry,
                  ),
                if (showRetryButton && showDismissButton)
                  const SizedBox(width: AppUIConfig.margin),
                if (showDismissButton)
                  CustomTextButton(
                    text: AppMessages.close,
                    icon: Icons.close,
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Organismo para mostrar errores en pantalla completa
class FullScreenError extends StatelessWidget {
  final Failure failure;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onBack;
  final bool showBackButton;

  const FullScreenError({
    super.key,
    required this.failure,
    this.title,
    this.onRetry,
    this.onBack,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          showBackButton
              ? AppBar(
                title: const TitleText(text: AppMessages.error),
                leading: IconButton(
                  icon: const CustomIcon(icon: Icons.arrow_back),
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                ),
              )
              : null,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppUIConfig.padding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const StatusIcon(status: 'error', size: 80),
              const SizedBox(height: AppUIConfig.padding * 1.5),
              TitleText(
                text: title ?? AppMessages.error,
                textAlign: TextAlign.center,
                color: AppColors.error,
              ),
              const SizedBox(height: AppUIConfig.padding),
              BodyText(
                text: failure.message,
                textAlign: TextAlign.center,
                color: AppColors.lightGrey600,
                maxLines: 5,
              ),
              const SizedBox(height: AppUIConfig.padding * 2),
              CustomButton(
                text: AppMessages.retry,
                icon: Icons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
