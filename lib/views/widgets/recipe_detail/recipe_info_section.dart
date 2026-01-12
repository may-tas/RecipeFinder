import 'package:flutter/material.dart';
import 'package:posha/utils/size_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';

class RecipeInfoSection extends StatelessWidget {
  final Recipe recipe;

  const RecipeInfoSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          recipe.name,
          style: AppTextStyles.h1.copyWith(fontSize: SizeConfig.getPercentSize(7)),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: SizeConfig.getPercentSize(3)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _InfoChip(
              icon: Icons.restaurant_menu_rounded,
              label: recipe.category,
            ),
            SizedBox(width: SizeConfig.getPercentSize(3)),
            _InfoChip(icon: Icons.public_rounded, label: recipe.area),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.getPercentSize(4), vertical: SizeConfig.getPercentSize(2.5)),
      decoration: BoxDecoration(
        color: AppColors.midGrey,
        borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.lightGrey, size: SizeConfig.getPercentSize(4)),
          SizedBox(width: SizeConfig.getPercentSize(2)),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }
}
