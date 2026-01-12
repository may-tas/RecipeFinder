import 'package:flutter/material.dart';
import 'package:posha/utils/size_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
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
              AppStrings.ingredientsCount(recipe.ingredients.length),
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
              padding: EdgeInsets.symmetric(vertical: SizeConfig.getPercentSize(3), horizontal: SizeConfig.getPercentSize(1)),
              color: index.isEven ? AppColors.darkGrey : AppColors.deepGrey,
              child: Row(
                children: [
                  SizedBox(width: SizeConfig.getPercentSize(3.5)),
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
