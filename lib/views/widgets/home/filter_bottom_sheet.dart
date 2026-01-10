import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posha/constants/app_strings.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';

void showFilterBottomSheet(BuildContext context) {
  final cubit = context.read<HomeCubit>();

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return BlocProvider.value(
        value: cubit,
        child: DefaultTabController(
          length: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle bar
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.midGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header with title and clear button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppStrings.filters, style: AppTextStyles.h3),
                      BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          final filterCount = cubit.activeFilterCount;

                          if (filterCount == 0) return const SizedBox.shrink();

                          return GestureDetector(
                            onTap: () {
                              cubit.clearFilters();
                              log("Cleared All");
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.accentRed.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.filter_alt_off,
                                    color: AppColors.accentRed,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(AppStrings.clearAll,
                                      style: AppTextStyles.h3.copyWith(
                                          color: AppColors.accentRed,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab bar
                TabBar(
                  indicatorColor: AppColors.white,
                  labelColor: AppColors.white,
                  unselectedLabelColor: AppColors.grey,
                  labelStyle: AppTextStyles.bodyMedium
                      .copyWith(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: AppStrings.filterArea),
                    Tab(text: AppStrings.filterIngredient),
                  ],
                ),

                // Tab views
                Expanded(
                  child: TabBarView(
                    children: [
                      _AreaFilterTab(),
                      _IngredientFilterTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _AreaFilterTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.areas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Skeletonizer(
              enabled: true,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.midGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(AppStrings.placeholderAreaName),
                  );
                },
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.areas.length,
            itemBuilder: (context, index) {
              final area = state.areas[index];
              final isSelected = state.selectedArea == area;
              return GestureDetector(
                onTap: () {
                  context.read<HomeCubit>().toggleAreaFilter(area);
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.buttonGradient : null,
                    color: isSelected ? null : AppColors.midGrey,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: AppColors.grey.withValues(alpha: 0.3),
                          ),
                  ),
                  child: Text(
                    area,
                    style: TextStyle(
                      color: isSelected ? AppColors.black : AppColors.lightGrey,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _IngredientFilterTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.ingredients.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Skeletonizer(
              enabled: true,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.midGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(AppStrings.placeholderIngredient),
                  );
                },
              ),
            ),
          );
        }

        // Show first 30 ingredients for better UX
        final displayIngredients = state.ingredients.take(30).toList();

        return Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayIngredients.length,
            itemBuilder: (context, index) {
              final ingredient = displayIngredients[index];
              final isSelected = state.selectedIngredient == ingredient;
              return GestureDetector(
                onTap: () async {
                  await context
                      .read<HomeCubit>()
                      .toggleIngredientFilter(ingredient);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppColors.buttonGradient : null,
                    color: isSelected ? null : AppColors.midGrey,
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: AppColors.grey.withValues(alpha: 0.3),
                          ),
                  ),
                  child: Text(
                    ingredient,
                    style: TextStyle(
                      color: isSelected ? AppColors.black : AppColors.lightGrey,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
