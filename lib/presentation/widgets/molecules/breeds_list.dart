import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../atoms/bovino_breed_card.dart';
import '../atoms/custom_text.dart';

class BreedsList extends StatelessWidget {
  final String? selectedBreed;
  final Function(String)? onBreedSelected;

  const BreedsList({super.key, this.selectedBreed, this.onBreedSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppUIConfig.padding,
            vertical: AppUIConfig.margin,
          ),
          child: SubtitleText(
            text: 'Razas de Ganado Bovino',
            color: Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),

        // Lista horizontal de razas
        SizedBox(
          height: 160,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppUIConfig.padding,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.knownBreeds.length,
            itemBuilder: (context, index) {
              final breed = AppConstants.knownBreeds[index];
              final isSelected = selectedBreed == breed;

              return BovinoBreedCard(
                breedName: breed,
                isSelected: isSelected,
                onTap: () => onBreedSelected?.call(breed),
              );
            },
          ),
        ),

        // Información adicional
        Padding(
          padding: const EdgeInsets.all(AppUIConfig.padding),
          child: Container(
            padding: const EdgeInsets.all(AppUIConfig.padding),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
              border: Border.all(
                color: AppColors.info.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: AppUIConfig.margin),
                Expanded(
                  child: CaptionText(
                    text:
                        'Selecciona una raza para ver información detallada o usa la cámara para análisis automático',
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
