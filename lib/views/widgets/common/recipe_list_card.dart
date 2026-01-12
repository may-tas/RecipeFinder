import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posha/utils/size_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';
import 'animated_favorite_button.dart';

class RecipeListCard extends StatelessWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const RecipeListCard({
    super.key,
    required this.recipe,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/details/${recipe.id}', extra: recipe),
      child: Container(
        height: SizeConfig.getPercentSize(25),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(3)),
          border: Border.all(color: AppColors.midGrey),
        ),
        padding: EdgeInsets.all(SizeConfig.getPercentSize(3)),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(2.5)),
              child: Hero(
                tag: 'recipe_image_${recipe.id}',
                child: CachedNetworkImage(
                  imageUrl: recipe.thumbUrl,
                  width: SizeConfig.getPercentSize(20),
                  height: SizeConfig.getPercentSize(20),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: SizeConfig.getPercentSize(20),
                    height: SizeConfig.getPercentSize(20),
                    color: AppColors.midGrey,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: SizeConfig.getPercentSize(20),
                    height: SizeConfig.getPercentSize(20),
                    color: AppColors.midGrey,
                    child: const Icon(Icons.restaurant, color: AppColors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(width: SizeConfig.getPercentSize(3)),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    recipe.name,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: SizeConfig.getPercentSize(4.5)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: SizeConfig.getPercentSize(1.5)),
                  if (recipe.category.isNotEmpty && recipe.area.isNotEmpty)
                    Text(
                      '${recipe.category} • ${recipe.area}',
                      style: AppTextStyles.cardMeta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (recipe.instructions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      recipe.instructions,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            // Favorite button
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: AnimatedFavoriteButton(
                isFavorite: isFavorite,
                onTap: onFavoriteToggle,
                size: 36,
                iconSize: 20,
                showBorder: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
