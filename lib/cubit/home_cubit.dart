import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import 'home_state.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiService _apiService;
  static const int _pageSize = 10;
  List<Recipe> _initialFeedRecipes = []; // Cache for reset

  HomeCubit(this._apiService) : super(const HomeState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final categories = await _apiService.getCategories();
      final areas = await _apiService.getAreas();
      final ingredients = await _apiService.getIngredients();
      // Load initial recipes (e.g., 'c' for Chicken/Cake)
      final recipes = await _apiService.getRecipesByFirstLetter('c');

      _initialFeedRecipes = recipes;

      _emitPaginatedState(
        allRecipes: recipes,
        categories: categories,
        areas: areas,
        ingredients: ingredients,
        status: HomeStatus.success,
      );
    } catch (e) {
      log("$e");
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: "Unknown error occurred, Please try again later",
        ),
      );
    }
  }

  void _emitPaginatedState({
    required List<Recipe> allRecipes,
    List<Category>? categories,
    List<String>? areas,
    List<String>? ingredients,
    required HomeStatus status,
    String? selectedCategory,
    String? selectedArea,
    String? selectedIngredient,
    bool clearSelectedArea = false,
    bool clearSelectedIngredient = false,
  }) {
    final firstPage = allRecipes.take(_pageSize).toList();
    emit(
      state.copyWith(
        allRecipes: allRecipes,
        recipes: firstPage,
        hasReachedMax: firstPage.length >= allRecipes.length,
        status: status,
        categories: categories ?? state.categories,
        areas: areas ?? state.areas,
        ingredients: ingredients ?? state.ingredients,
        selectedCategory: selectedCategory ?? state.selectedCategory,
        selectedArea:
            clearSelectedArea ? null : (selectedArea ?? state.selectedArea),
        selectedIngredient: clearSelectedIngredient
            ? null
            : (selectedIngredient ?? state.selectedIngredient),
      ),
    );
  }

  // Apply all active filters to a recipe list
  List<Recipe> _applyFilters(List<Recipe> recipes) {
    List<Recipe> filtered = recipes;

    // Filter by category
    if (state.selectedCategory != 'All') {
      filtered = filtered
          .where((r) =>
              r.category.toLowerCase() == state.selectedCategory.toLowerCase())
          .toList();
    }

    // Filter by area
    if (state.selectedArea != null) {
      filtered = filtered
          .where(
              (r) => r.area.toLowerCase() == state.selectedArea!.toLowerCase())
          .toList();
    }

    // Filter by ingredient
    if (state.selectedIngredient != null) {
      filtered = filtered
          .where((r) => r.ingredients.any((ing) => ing
              .toLowerCase()
              .contains(state.selectedIngredient!.toLowerCase())))
          .toList();
    }

    return filtered;
  }

  // Re-apply current filters to the initial feed
  Future<void> _reapplyFilters() async {
    emit(state.copyWith(status: HomeStatus.loading));
    await Future.delayed(const Duration(milliseconds: 300));

    final filtered = _applyFilters(_initialFeedRecipes);
    _emitPaginatedState(
      allRecipes: filtered,
      status: HomeStatus.success,
    );
  }

  Future<void> loadMore() async {
    // Don't load more if already loading, max reached, or no recipes
    if (state.isLoadingMore ||
        state.hasReachedMax ||
        state.allRecipes.isEmpty) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    await Future.delayed(const Duration(milliseconds: 1000));

    final currentLength = state.recipes.length;
    final nextChunk =
        state.allRecipes.skip(currentLength).take(_pageSize).toList();

    if (nextChunk.isEmpty) {
      emit(state.copyWith(
        hasReachedMax: true,
        isLoadingMore: false,
      ));
    } else {
      emit(
        state.copyWith(
          recipes: List.of(state.recipes)..addAll(nextChunk),
          hasReachedMax: (state.recipes.length + nextChunk.length) >=
              state.allRecipes.length,
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> searchRecipes(String query) async {
    if (query.isEmpty) {
      // Reset to initial feed
      _emitPaginatedState(
        allRecipes: _initialFeedRecipes,
        status: HomeStatus.success,
      );
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final recipes = await _apiService.searchRecipes(query);
      _emitPaginatedState(allRecipes: recipes, status: HomeStatus.success);
    } catch (e) {
      log("$e");
      emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: "Unknown error occurred, Please try again later",
        ),
      );
    }
  }

  Future<void> filterByCategory(String category) async {
    emit(
        state.copyWith(status: HomeStatus.loading, selectedCategory: category));
    await Future.delayed(const Duration(milliseconds: 300));

    final filtered = _applyFilters(_initialFeedRecipes);
    _emitPaginatedState(
      allRecipes: filtered,
      status: HomeStatus.success,
    );
  }

  Future<void> filterByArea(String area) async {
    emit(state.copyWith(status: HomeStatus.loading, selectedArea: area));
    await Future.delayed(const Duration(milliseconds: 300));

    final filtered = _applyFilters(_initialFeedRecipes);
    _emitPaginatedState(
      allRecipes: filtered,
      status: HomeStatus.success,
    );
  }

  Future<void> refresh() async {
    emit(state.copyWith(status: HomeStatus.loading));
    await Future.delayed(const Duration(milliseconds: 1000));

    // If any filters are active, reapply them
    if (activeFilterCount > 0) {
      await _reapplyFilters();
    } else {
      // Reload initial data
      await _loadInitialData();
    }
  }

  void clearFilters() {
    _emitPaginatedState(
      allRecipes: _initialFeedRecipes,
      status: HomeStatus.success,
      selectedCategory: 'All',
      clearSelectedArea: true,
      clearSelectedIngredient: true,
    );
  }

  void selectCategory(String category) {
    final newCategory =
        (state.selectedCategory == category && category != 'All')
            ? 'All'
            : category;
    filterByCategory(newCategory);
  }

  void toggleAreaFilter(String area) {
    final isCurrentlySelected = state.selectedArea == area;
    if (isCurrentlySelected) {
      // Deselect
      emit(state.copyWith(selectedArea: null));
    } else {
      // Select
      emit(state.copyWith(selectedArea: area));
    }
    _reapplyFilters();
  }

  Future<void> toggleIngredientFilter(String ingredient) async {
    final isCurrentlySelected = state.selectedIngredient == ingredient;

    if (isCurrentlySelected) {
      // Deselect
      emit(state.copyWith(selectedIngredient: null));
    } else {
      // Select
      emit(state.copyWith(selectedIngredient: ingredient));
    }
    await _reapplyFilters();
  }

  // Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (state.selectedCategory != 'All') count++;
    if (state.selectedArea != null) count++;
    if (state.selectedIngredient != null) count++;
    return count;
  }

  void toggleViewMode() {
    emit(state.copyWith(isGridView: !state.isGridView));
  }
}
