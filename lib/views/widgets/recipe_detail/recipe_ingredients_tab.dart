import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';

class RecipeIngredientsTab extends StatelessWidget {
  final Recipe recipe;

  const RecipeIngredientsTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ingredients (${recipe.ingredients.length})',
              style: AppTextStyles.h3,
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recipe.ingredients.length,
          separatorBuilder: (_, __) =>
              const Divider(color: AppColors.midGrey, height: 1),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              color: index.isEven ? AppColors.darkGrey : AppColors.deepGrey,
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      recipe.ingredients[index],
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),
                  Text(
                    recipe.measures[index],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
