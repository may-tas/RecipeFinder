import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_colors.dart';
import '../../cubit/recipe_detail_cubit.dart';
import '../../cubit/recipe_detail_state.dart';
import '../../injection_container.dart';
import '../../models/recipe_model.dart';
import '../../utils/app_snackbar.dart';
import '../widgets/recipe_detail/recipe_sliver_app_bar.dart';
import '../widgets/recipe_detail/recipe_info_section.dart';
import '../widgets/recipe_detail/recipe_overview_tab.dart';
import '../widgets/recipe_detail/recipe_ingredients_tab.dart';
import '../widgets/recipe_detail/recipe_instructions_tab.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;
  final Recipe? recipe;

  const RecipeDetailScreen({super.key, required this.recipeId, this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          locator<RecipeDetailCubit>()
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

          if (recipe == null && state.status == RecipeDetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            );
          }

          if (recipe == null) {
            return const Center(
              child: Text(
                'Recipe not found',
                style: TextStyle(color: AppColors.white),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              RecipeSliverAppBar(recipe: recipe),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.backgroundGradient,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        RecipeInfoSection(recipe: recipe),
                        const SizedBox(height: 24),
                        _buildTabBar(),
                        const SizedBox(height: 16),
                        _buildTabContent(recipe),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
        builder: (context, state) {
          return FloatingActionButton(
            backgroundColor: AppColors.white,
            onPressed: () => context.read<RecipeDetailCubit>().toggleFavorite(),
            child: Icon(
              state.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: state.isFavorite ? AppColors.accentRed : AppColors.black,
            ),
          );
        },
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
          Tab(text: 'Overview'),
          Tab(text: 'Ingredients'),
          Tab(text: 'Instructions'),
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
