import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_colors.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';
import '../common/app_filter_chip.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.categories != current.categories ||
          previous.selectedCategory != current.selectedCategory,
      builder: (context, state) {
        if (state.categories.isEmpty && state.status == HomeStatus.loading) {
          return const SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          );
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final categoryName = isAll
                  ? 'All'
                  : state.categories[index - 1].name;
              final isSelected = state.selectedCategory == categoryName;

              return AppFilterChip(
                label: categoryName,
                isSelected: isSelected,
                onTap: () {
                  context.read<HomeCubit>().filterByCategory(categoryName);
                },
              );
            },
          ),
        );
      },
    );
  }
}
