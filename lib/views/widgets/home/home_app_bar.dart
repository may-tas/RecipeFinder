import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Discover Recipes', style: AppTextStyles.h1),
              BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      _ViewToggleButton(
                        icon: Icons.grid_view_rounded,
                        isSelected: state.isGridView,
                        onTap: () {
                          if (!state.isGridView) {
                            context.read<HomeCubit>().toggleViewMode();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _ViewToggleButton(
                        icon: Icons.view_list_rounded,
                        isSelected: !state.isGridView,
                        onTap: () {
                          if (state.isGridView) {
                            context.read<HomeCubit>().toggleViewMode();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.midGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppColors.white : AppColors.grey,
          size: 24,
        ),
      ),
    );
  }
}
