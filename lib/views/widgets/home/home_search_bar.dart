import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_strings.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';
import '../common/app_search_bar.dart';
import 'filter_bottom_sheet.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final cubit = context.read<HomeCubit>();
        final filterCount = cubit.activeFilterCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppSearchBar(
            hintText: AppStrings.searchRecipesHint,
            onChanged: (query) => cubit.searchRecipes(query),
            onSortTap: () => cubit.toggleSortOrder(),
            isSortedAscending: state.sortOrder == SortOrder.aToZ,
            onFilterTap: () => showFilterBottomSheet(context),
            filterCount: filterCount,
          ),
        );
      },
    );
  }
}
