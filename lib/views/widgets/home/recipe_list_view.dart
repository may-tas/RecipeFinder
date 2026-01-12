import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posha/utils/size_config.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';
import '../../../models/recipe_model.dart';
import '../../../services/local_storage_service.dart';
import '../../../injection_container.dart';
import '../common/recipe_grid_card.dart';
import '../common/recipe_list_card.dart';

class RecipeListView extends StatefulWidget {
  const RecipeListView({super.key});

  @override
  State<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  final ScrollController _scrollController = ScrollController();
  late final LocalStorageService _localStorageService;
  late final ValueNotifier<int> _favoritesNotifier;

  @override
  void initState() {
    super.initState();
    _localStorageService = locator<LocalStorageService>();
    _favoritesNotifier = ValueNotifier<int>(0);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _favoritesNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HomeCubit>().loadMore();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _onRefresh() async {
    // Reload the current view state
    final cubit = context.read<HomeCubit>();
    await cubit.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.failure) {
          return _buildErrorState(state.errorMessage);
        }

        // Show initial loading skeleton when status is loading
        // (This happens on first load AND refresh)
        final isInitialLoading = state.status == HomeStatus.loading;

        // Show bottom spinner when pagination is active
        final isPaginationLoading = state.isLoadingMore;

        final recipes = state.recipes;

        if (recipes.isEmpty && !isInitialLoading) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.white,
            backgroundColor: AppColors.darkGrey,
            child: _buildEmptyState(),
          );
        }

        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.white,
          backgroundColor: AppColors.darkGrey,
          child: state.isGridView
              ? _buildGridView(recipes, state.hasReachedMax, isInitialLoading,
                  isPaginationLoading)
              : _buildListView(recipes, state.hasReachedMax, isInitialLoading,
                  isPaginationLoading),
        );
      },
    );
  }

  Widget _buildGridView(
    List<Recipe> recipes,
    bool hasReachedMax,
    bool isInitialLoading,
    bool isPaginationLoading,
  ) {
    // Calculate item count:
    // If initial loading -> 6 placeholders
    // If not -> recipes.length
    final int gridItemCount = isInitialLoading ? 6 : recipes.length;

    return Skeletonizer(
      enabled: isInitialLoading,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.all(SizeConfig.getPercentSize(4)),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: SizeConfig.getPercentSize(4),
                mainAxisSpacing: SizeConfig.getPercentSize(4),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isInitialLoading) {
                    return RecipeGridCard(recipe: _createPlaceholderRecipe());
                  }
                  final recipe = recipes[index];
                  return ValueListenableBuilder<int>(
                    valueListenable: _favoritesNotifier,
                    builder: (context, _, __) {
                      return RecipeGridCard(
                        recipe: recipe,
                        isFavorite: _localStorageService.isFavorite(recipe.id),
                        onFavoriteToggle: () async {
                          await _localStorageService.toggleFavorite(recipe);
                          _favoritesNotifier.value++; // Trigger rebuild
                        },
                      );
                    },
                  );
                },
                childCount: gridItemCount,
              ),
            ),
          ),
          if (!isInitialLoading)
            SliverToBoxAdapter(
              child: isPaginationLoading
                  ? Container(
                      height: SizeConfig.getPercentSize(15),
                      alignment: Alignment.center,
                      child:  CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: SizeConfig.getPercentSize(0.5),
                      ),
                    )
                  : SizedBox(height: SizeConfig.getPercentSize(5)),
            ),
        ],
      ),
    );
  }

  Widget _buildListView(
    List<Recipe> recipes,
    bool hasReachedMax,
    bool isInitialLoading,
    bool isPaginationLoading,
  ) {
    final displayRecipes = recipes;

    return Skeletonizer(
      enabled: isInitialLoading,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(SizeConfig.getPercentSize(4)),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: isInitialLoading
            ? 6
            : displayRecipes.length + (hasReachedMax ? 0 : 1),
        separatorBuilder: (_, __) => SizedBox(height: SizeConfig.getPercentSize(3)),
        itemBuilder: (context, index) {
          if (isInitialLoading) {
            return RecipeListCard(recipe: _createPlaceholderRecipe());
          }
          if (index >= displayRecipes.length) {
            // Loading more indicator
            if (isPaginationLoading) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.getPercentSize(4)),
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2,
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          }
          final recipe = displayRecipes[index];
          return ValueListenableBuilder<int>(
            valueListenable: _favoritesNotifier,
            builder: (context, _, __) {
              return RecipeListCard(
                recipe: recipe,
                isFavorite: _localStorageService.isFavorite(recipe.id),
                onFavoriteToggle: () async {
                  await _localStorageService.toggleFavorite(recipe);
                  _favoritesNotifier.value++; // Trigger rebuild
                },
              );
            },
          );
        },
      ),
    );
  }

  Recipe _createPlaceholderRecipe() {
    return Recipe(
      id: 'placeholder',
      name: AppStrings.placeholderRecipeName,
      category: AppStrings.placeholderCategory,
      area: AppStrings.placeholderArea,
      instructions: 'Loading instructions...',
      thumbUrl: '',
      ingredients: ['Ingredient 1', 'Ingredient 2'],
      measures: ['1 cup', '2 tbsp'],
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded, size: SizeConfig.getPercentSize(16), color: AppColors.grey),
              SizedBox(height: SizeConfig.getPercentSize(4)),
              Text(
                AppStrings.noRecipesFound,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: SizeConfig.getPercentSize(5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: SizeConfig.getPercentSize(2)),
              Text(
                AppStrings.tryAdjustingFilters,
                style: TextStyle(color: AppColors.grey, fontSize: SizeConfig.getPercentSize(3.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: SizeConfig.getPercentSize(16),
            color: AppColors.accentRed,
          ),
          SizedBox(height: SizeConfig.getPercentSize(4)),
          Text(
            AppStrings.failedToLoadRecipes,
            style: TextStyle(
              color: AppColors.white,
              fontSize: SizeConfig.getPercentSize(5),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeConfig.getPercentSize(2)),
          Text(
            message,
            style: TextStyle(color: AppColors.grey, fontSize: SizeConfig.getPercentSize(3.5)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeConfig.getPercentSize(6)),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
            ),
            child: Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}
