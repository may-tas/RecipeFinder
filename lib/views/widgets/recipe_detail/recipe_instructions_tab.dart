import 'package:flutter/material.dart';
import 'package:posha/utils/size_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';

class RecipeInstructionsTab extends StatelessWidget {
  final Recipe recipe;

  const RecipeInstructionsTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final steps = recipe.instructions
        .split(RegExp(r'\r\n|\r|\n'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (steps.isEmpty) {
      return Text(
        recipe.instructions,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.lightGrey,
          height: 1.8,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.instructionsSteps(steps.length),
            style: AppTextStyles.h3),
        SizedBox(height: SizeConfig.getPercentSize(4)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          separatorBuilder: (_, __) => SizedBox(height: SizeConfig.getPercentSize(3)),
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(SizeConfig.getPercentSize(5)),
              decoration: BoxDecoration(
                color: AppColors.midGrey,
                borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: SizeConfig.getPercentSize(8),
                    height: SizeConfig.getPercentSize(8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(2)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.button.copyWith(fontSize: SizeConfig.getPercentSize(3.5)),
                    ),
                  ),
                  SizedBox(width: SizeConfig.getPercentSize(4)),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.lightGrey,
                        height: 1.8,
                      ),
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
