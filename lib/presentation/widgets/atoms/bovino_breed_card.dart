import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_ui_config.dart';
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
      child:  Container(
        width: AppUIConfig.bovinoCardWidth,
        height: AppUIConfig.bovinoCardHeight,
        margin: const EdgeInsetsDirectional.only(end: AppUIConfig.margin),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppUIConfig.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey300,
            width: isSelected ? AppUIConfig.borderWidthThick : AppUIConfig.borderWidth,
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
                  borderRadius: BorderRadiusDirectional.only(
                    topStart: Radius.circular(AppUIConfig.borderRadius),
                    topEnd: Radius.circular(AppUIConfig.borderRadius),
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
                            borderRadius: BorderRadiusDirectional.only(
                              topStart: Radius.circular(
                                AppUIConfig.borderRadius,
                              ),
                              topEnd: Radius.circular(
                                AppUIConfig.borderRadius,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.pets,
                            size: AppUIConfig.iconSizeLarge,
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
                  borderRadius: BorderRadiusDirectional.only(
                    bottomStart: Radius.circular(AppUIConfig.borderRadius),
                    bottomEnd: Radius.circular(AppUIConfig.borderRadius),
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
