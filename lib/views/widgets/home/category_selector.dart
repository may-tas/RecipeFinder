import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posha/utils/size_config.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../constants/app_strings.dart';
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
          return Container(
            margin:
                EdgeInsets.symmetric(vertical: SizeConfig.getPercentSize(3)),
            height: SizeConfig.getPercentSize(10),
            child: Skeletonizer(
              enabled: true,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.getPercentSize(4),
                ),
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) =>
                    SizedBox(width: SizeConfig.getPercentSize(2)),
                itemBuilder: (_, __) => AppFilterChip(
                  label: AppStrings.placeholderCategoryName,
                  isSelected: false,
                ),
              ),
            ),
          );
        }

        return Container(
          height: SizeConfig.getPercentSize(10),
          margin: EdgeInsets.symmetric(vertical: SizeConfig.getPercentSize(3)),
          child: ListView.separated(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.getPercentSize(4)),
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length + 1,
            separatorBuilder: (_, __) =>
                SizedBox(width: SizeConfig.getPercentSize(2)),
            itemBuilder: (context, index) {
              final isAll = index == 0;
              final categoryName = isAll
                  ? AppStrings.categoryAll
                  : state.categories[index - 1].name;
              final isSelected = state.selectedCategory == categoryName;

              return AppFilterChip(
                label: categoryName,
                isSelected: isSelected,
                onTap: () {
                  context.read<HomeCubit>().selectCategory(categoryName);
                },
              );
            },
          ),
        );
      },
    );
  }
}
