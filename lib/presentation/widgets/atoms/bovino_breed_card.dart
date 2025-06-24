import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'custom_text.dart';

class BovinoBreedCard extends StatelessWidget {
  final String breedName;
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool isSelected;

  const BovinoBreedCard({
    super.key,
    required this.breedName,
    this.imageUrl,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        height: 140,
        margin: const EdgeInsets.only(right: AppUIConfig.margin),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey300,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: AppUIConfig.cardShadow,
        ),
        child: Column(
          children: [
            // Imagen del bovino
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppUIConfig.borderRadius),
                    topRight: Radius.circular(AppUIConfig.borderRadius),
                  ),
                  image: DecorationImage(
                    image:
                        imageUrl != null
                            ? NetworkImage(imageUrl!)
                            : const AssetImage(
                                  'assets/images/default_bovino.png',
                                )
                                as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child:
                    imageUrl == null
                        ? Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(
                                AppUIConfig.borderRadius,
                              ),
                              topRight: Radius.circular(
                                AppUIConfig.borderRadius,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.pets,
                            size: 32,
                            color: AppColors.lightGrey,
                          ),
                        )
                        : null,
              ),
            ),
            // Nombre de la raza
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppUIConfig.margin,
                  vertical: AppUIConfig.margin / 2,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppUIConfig.borderRadius),
                    bottomRight: Radius.circular(AppUIConfig.borderRadius),
                  ),
                ),
                child: Center(
                  child: CaptionText(
                    text: breedName,
                    textAlign: TextAlign.center,
                    color: isSelected ? AppColors.primary : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
