import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:posha/utils/size_config.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../constants/app_colors.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';
import '../../../models/recipe_model.dart';
import '../common/recipe_grid_card.dart';
import '../common/recipe_list_card.dart';

class RecipeListView extends StatefulWidget {
  const RecipeListView({super.key});

  @override
  State<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (isInitialLoading) {
                    return RecipeGridCard(recipe: _createPlaceholderRecipe());
                  }
                  return RecipeGridCard(recipe: recipes[index]);
                },
                childCount: gridItemCount,
              ),
            ),
          ),
          if (!isInitialLoading)
            SliverToBoxAdapter(
              child: isPaginationLoading
                  ? Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const SizedBox(height: 20),
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
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: isInitialLoading
            ? 6
            : displayRecipes.length + (hasReachedMax ? 0 : 1),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
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
          return RecipeListCard(recipe: displayRecipes[index]);
        },
      ),
    );
  }

  Recipe _createPlaceholderRecipe() {
    return const Recipe(
      id: 'placeholder',
      name: 'Loading Recipe Name',
      category: 'Category',
      area: 'Area',
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
              Icon(Icons.search_off_rounded, size: 64, color: AppColors.grey),
              const SizedBox(height: 16),
              Text(
                'No recipes found',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
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
            size: 64,
            color: AppColors.accentRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load recipes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: AppColors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
