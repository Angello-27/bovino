import 'package:flutter/material.dart';
import '../../../domain/entities/bovino_entity.dart';
import '../../../core/constants/app_constants.dart';
import '../atoms/info_card.dart';

class AnalysisResultCard extends StatelessWidget {
  final BovinoEntity bovino;
  final VoidCallback? onTap;

  const AnalysisResultCard({
    super.key,
    required this.bovino,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.defaultElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.agriculture,
                    color: const Color(AppConstants.primaryColor),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bovino.raza,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bovino.esAnalisisConfiable
                          ? const Color(AppConstants.successColor)
                          : const Color(AppConstants.warningColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bovino.confianzaFormateada,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      title: 'Peso Estimado',
                      value: bovino.pesoFormateado,
                      icon: Icons.monitor_weight,
                      color: const Color(AppConstants.warningColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InfoCard(
                      title: 'Fecha',
                      value: _formatDate(bovino.fechaAnalisis),
                      icon: Icons.calendar_today,
                      color: const Color(AppConstants.secondaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                bovino.descripcion,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 