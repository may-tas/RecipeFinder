import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';
import '../../../constants/app_colors.dart';
import '../common/app_search_bar.dart';
import 'filter_bottom_sheet.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  int _getActiveFilterCount(HomeState state) {
    int count = 0;
    if (state.selectedCategory != 'All') count++;
    if (state.selectedArea != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final filterCount = _getActiveFilterCount(state);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              AppSearchBar(
                hintText: 'Search recipes...',
                onChanged: (query) =>
                    context.read<HomeCubit>().searchRecipes(query),
                onFilterTap: () => showFilterBottomSheet(context),
              ),
              if (filterCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accentRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$filterCount',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
