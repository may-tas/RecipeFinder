import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../cubit/recipe_detail_cubit.dart';
import '../../cubit/recipe_detail_state.dart';
import '../../injection_container.dart';
import '../../models/recipe_model.dart';
import '../../utils/app_snackbar.dart';
import '../widgets/common/animated_favorite_button.dart';
import '../widgets/recipe_detail/recipe_info_section.dart';
import '../widgets/recipe_detail/recipe_overview_tab.dart';
import '../widgets/recipe_detail/recipe_ingredients_tab.dart';
import '../widgets/recipe_detail/recipe_instructions_tab.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  final Recipe? recipe;

  const RecipeDetailScreen({super.key, required this.recipeId, this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<RecipeDetailCubit>()
        ..loadRecipe(recipeId, placeholder: recipe),
      child: const RecipeDetailView(),
    );
  }
}

class RecipeDetailView extends StatefulWidget {
  const RecipeDetailView({super.key});

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepGrey,
      body: BlocConsumer<RecipeDetailCubit, RecipeDetailState>(
        listener: (context, state) {
          if (state.status == RecipeDetailStatus.failure) {
            AppSnackbar.showError(context, state.errorMessage);
          }
        },
        builder: (context, state) {
          final recipe = state.recipe;
          final showSkeleton =
              state.status == RecipeDetailStatus.loading || state.isHydrating;

          if (recipe == null && showSkeleton) {
            return _buildLoadingSkeleton();
          }

          if (recipe == null) {
            return const Center(
              child: Text(
                AppStrings.recipeNotFound,
                style: TextStyle(color: AppColors.white),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(recipe, state.isFavorite),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                  ),
                  child: Skeletonizer(
                    enabled: showSkeleton,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          RecipeInfoSection(recipe: recipe),
                          const SizedBox(height: 24),
                          _buildTabBar(),
                          const SizedBox(height: 30),
                          _buildTabContent(recipe),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            backgroundColor: AppColors.deepGrey,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: AppColors.midGrey),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.backgroundGradient,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      height: 32,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.midGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.6,
                      decoration: BoxDecoration(
                        color: AppColors.midGrey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.midGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.midGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Recipe recipe, bool isFavorite) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      backgroundColor: AppColors.deepGrey,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _GlassmorphicButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedFavoriteButton(
            isFavorite: isFavorite,
            onTap: () => context.read<RecipeDetailCubit>().toggleFavorite(),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            context.push(
              '/image-viewer',
              extra: {
                'imageUrl': recipe.thumbUrl,
                'tag': 'recipe_image_${recipe.id}',
              },
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'recipe_image_${recipe.id}',
                child: CachedNetworkImage(
                  imageUrl: recipe.thumbUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.midGrey),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.midGrey,
                    child: const Icon(Icons.restaurant,
                        color: AppColors.grey, size: 48),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.imageOverlayGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.midGrey),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.grey,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.midGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: AppStrings.tabOverview),
          Tab(text: AppStrings.tabIngredients),
          Tab(text: AppStrings.tabInstructions),
        ],
      ),
    );
  }

  Widget _buildTabContent(Recipe recipe) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        switch (_tabController.index) {
          case 0:
            return RecipeOverviewTab(recipe: recipe);
          case 1:
            return RecipeIngredientsTab(recipe: recipe);
          case 2:
            return RecipeInstructionsTab(recipe: recipe);
          default:
            return const SizedBox();
        }
      },
    );
  }
}

class _GlassmorphicButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassmorphicButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.midGrey),
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}
