import 'package:flutter/material.dart';
import 'package:posha/utils/size_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.getPercentSize(3),
            vertical: SizeConfig.getPercentSize(2)),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.buttonGradient : null,
          color: isSelected ? null : AppColors.midGrey,
          borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(5)),
          border: isSelected
              ? null
              : Border.all(color: AppColors.midGrey.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.black : AppColors.lightGrey,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: SizeConfig.getPercentSize(3.25),
          ),
        ),
      ),
    );
  }
}
