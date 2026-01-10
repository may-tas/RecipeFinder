import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../cubit/favorites_cubit.dart';
import '../../cubit/favorites_state.dart';
import '../widgets/common/recipe_list_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FavoritesView();
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.favoritesTitle, style: AppTextStyles.h1),
                const SizedBox(height: 4),
                BlocBuilder<FavoritesCubit, FavoritesState>(
                  builder: (context, state) {
                    return Text(
                      '${state.favorites.length} recipes',
                      style: AppTextStyles.bodyMedium,
                    );
                  },
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state.status == FavoritesStatus.loading) {
                  return _buildLoadingSkeleton();
                }

                if (state.favorites.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final recipe = state.favorites[index];
                    return Dismissible(
                      key: Key(recipe.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: AppColors.accentRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.delete_rounded,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (_) {
                        context
                            .read<FavoritesCubit>()
                            .removeFavorite(recipe.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Removed from favorites'),
                            backgroundColor: AppColors.midGrey,
                            action: SnackBarAction(
                              label: 'Undo',
                              textColor: AppColors.white,
                              onPressed: () {
                                context
                                    .read<FavoritesCubit>()
                                    .addFavorite(recipe);
                              },
                            ),
                          ),
                        );
                      },
                      child: RecipeListCard(
                        recipe: recipe,
                        isFavorite: true,
                        onFavoriteToggle: () {
                          context
                              .read<FavoritesCubit>()
                              .removeFavorite(recipe.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'No favorites yet',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Browse recipes and tap the heart to save your favorites',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Browse Recipes', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}
