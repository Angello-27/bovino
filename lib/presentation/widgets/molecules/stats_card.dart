import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../atoms/custom_text.dart';

class StatsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? color;

  const StatsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppUIConfig.padding),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
          border: Border.all(
            color: color?.withValues(alpha: 0.3) ?? AppColors.lightGrey300,
            width: 1,
          ),
          boxShadow: AppUIConfig.cardShadow,
        ),
        child: Column(
          children: [
            // Icono
            Icon(icon, size: 32, color: color ?? AppColors.primary),

            const SizedBox(height: AppUIConfig.margin),

            // Valor
            TitleText(
              text: value,
              fontSize: 20,
              color: color ?? AppColors.primary,
            ),

            const SizedBox(height: AppUIConfig.margin / 2),

            // Título
            CaptionText(
              text: title,
              textAlign: TextAlign.center,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppUIConfig.padding),
      child: Row(
        children: [
          const StatsCard(
            icon: Icons.camera_alt,
            title: 'Razas Detectadas',
            value: '20',
            color: AppColors.primary,
          ),
          const SizedBox(width: AppUIConfig.margin),
          const StatsCard(
            icon: Icons.psychology,
            title: 'Análisis IA',
            value: '100%',
            color: AppColors.info,
          ),
          const SizedBox(width: AppUIConfig.margin),
          const StatsCard(
            icon: Icons.scale,
            title: 'Peso Estimado',
            value: 'Sí',
            color: AppColors.success,
          ),
        ],
      ),
    );
  }
}
