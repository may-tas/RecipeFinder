import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
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
        Text('Instructions (${steps.length} steps)', style: AppTextStyles.h3),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.midGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.button.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
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
