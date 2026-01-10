import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../constants/app_colors.dart';
import '../../../cubit/home_cubit.dart';
import '../../../cubit/home_state.dart';
import '../../../models/recipe_model.dart';
import '../common/recipe_grid_card.dart';
import '../common/recipe_list_card.dart';
import '../common/shimmer_skeleton.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state.status == HomeStatus.failure) {
          return _buildErrorState(state.errorMessage);
        }

        final isLoading = state.status == HomeStatus.loading;
        final recipes = state.recipes;

        if (recipes.isEmpty && isLoading) {
          return _buildSkeletonView(state.isGridView);
        }

        if (recipes.isEmpty && !isLoading) {
          return _buildEmptyState();
        }

        return state.isGridView
            ? _buildGridView(recipes, state.hasReachedMax, isLoading)
            : _buildListView(recipes, state.hasReachedMax, isLoading);
      },
    );
  }

  Widget _buildGridView(
    List<Recipe> recipes,
    bool hasReachedMax,
    bool isLoading,
  ) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: recipes.length + (hasReachedMax || isLoading ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= recipes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          );
        }
        return RecipeGridCard(recipe: recipes[index]);
      },
    );
  }

  Widget _buildListView(
    List<Recipe> recipes,
    bool hasReachedMax,
    bool isLoading,
  ) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length + (hasReachedMax || isLoading ? 0 : 1),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index >= recipes.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.white),
            ),
          );
        }
        return RecipeListCard(recipe: recipes[index]);
      },
    );
  }

  Widget _buildSkeletonView(bool isGridView) {
    if (isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const RecipeGridCardSkeleton(),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const RecipeListCardSkeleton(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
            onPressed: () => context.read<HomeCubit>().searchRecipes(''),
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
