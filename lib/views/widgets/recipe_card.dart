import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/recipe_model.dart';
import '../../utils/size_config.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final bool isList;

  const RecipeCard({super.key, required this.recipe, this.isList = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/details/${recipe.id}', extra: recipe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(4)),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: SizeConfig.getPercentSize(3),
              offset: Offset(0, SizeConfig.getPercentSize(1)),
            ),
          ],
        ),
        child: isList ? _buildListView() : _buildGridView(),
      ),
    );
  }

  Widget _buildGridView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SizeConfig.getPercentSize(4)),
          ),
          child: Hero(
            tag: 'recipe_image_${recipe.id}',
            child: CachedNetworkImage(
              imageUrl: recipe.thumbUrl,
              height: SizeConfig.getPercentSize(18), // Adjust as per need
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.getPercentSize(1)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  recipe.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${recipe.area} • ${recipe.category}',
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "30 min",
                      style: AppTextStyles.bodySmall,
                    ), // Placeholder logic
                    const Spacer(),
                    // Could indicate favorite here but requires lookup
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(SizeConfig.getPercentSize(4)),
          ),
          child: Hero(
            tag: 'recipe_image_${recipe.id}',
            child: CachedNetworkImage(
              imageUrl: recipe.thumbUrl,
              height: SizeConfig.getPercentSize(15),
              width: SizeConfig.getPercentSize(15),
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(SizeConfig.getPercentSize(3)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  recipe.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeConfig.getPercentSize(1)),
                Text(
                  '${recipe.area} • ${recipe.category}',
                  style: AppTextStyles.bodySmall,
                ),
                SizedBox(height: SizeConfig.getPercentSize(2)),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text("30 min", style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
