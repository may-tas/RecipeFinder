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
        selectedArea: selectedArea ?? state.selectedArea,
        selectedIngredient: selectedIngredient ?? state.selectedIngredient,
      ),
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
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      List<Recipe> recipes;
      if (category == 'All') {
        recipes = _initialFeedRecipes;
      } else {
        recipes = await _apiService.filterByCategory(category);
      }

      _emitPaginatedState(
        allRecipes: recipes,
        status: HomeStatus.success,
        selectedCategory: category,
        selectedArea: null, // Reset area filter
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

  Future<void> filterByArea(String area) async {
    // Status is set to loading by the caller (refresh/selectArea)
    // but we ensure it here just in case direct call
    if (state.status != HomeStatus.loading) {
      emit(state.copyWith(status: HomeStatus.loading));
    }
    try {
      final recipes = await _apiService.filterByArea(area);
      _emitPaginatedState(
        allRecipes: recipes,
        status: HomeStatus.success,
        selectedCategory: 'All', // Reset category filter
        selectedArea: area,
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

  Future<void> refresh() async {
    // Artificial delay to show skeleton loading state
    // purely for UX so users see the refresh happening
    emit(state.copyWith(status: HomeStatus.loading));
    await Future.delayed(const Duration(milliseconds: 1000));

    // Refresh based on current state
    if (state.selectedArea != null) {
      await filterByArea(state.selectedArea!);
    } else if (state.selectedCategory != 'All') {
      await filterByCategory(state.selectedCategory);
    } else {
      // Reload initial data
      await _loadInitialData();
    }
  }

  // Ingredient filtering is done via API, no client-side matching needed

  // Apply client-side filters to recipe list
  List<Recipe> _applyClientFilters(List<Recipe> recipes) {
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

    // Ingredient filtering is handled by API, not client-side
    // If ingredient is selected, we fetch from API directly
    if (state.selectedIngredient != null) {
      // This shouldn't happen in normal flow as ingredient uses API
      // But keep for safety
    }

    return filtered;
  }

  // Apply client-side filters with explicit state (for toggle operations)
  List<Recipe> _applyClientFiltersWithState(
      List<Recipe> recipes, HomeState filterState) {
    List<Recipe> filtered = recipes;

    // Filter by category
    if (filterState.selectedCategory != 'All') {
      filtered = filtered
          .where((r) =>
              r.category.toLowerCase() ==
              filterState.selectedCategory.toLowerCase())
          .toList();
    }

    // Filter by area
    if (filterState.selectedArea != null) {
      filtered = filtered
          .where((r) =>
              r.area.toLowerCase() == filterState.selectedArea!.toLowerCase())
          .toList();
    }

    // Ingredient filtering is handled by API, not client-side
    if (filterState.selectedIngredient != null) {
      // This shouldn't happen in normal flow
    }

    return filtered;
  }

  // Clear all filters
  void clearFilters() {
    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedCategory: 'All',
      selectedArea: null,
      selectedIngredient: null,
    ));

    // Reset to initial feed
    _emitPaginatedState(
      allRecipes: _initialFeedRecipes,
      status: HomeStatus.success,
      selectedCategory: 'All',
      selectedArea: null,
      selectedIngredient: null,
    );
  }

  // Toggle category selection
  void selectCategory(String category) {
    if (state.selectedCategory == category && category != 'All') {
      // Deselect -> go back to 'All'
      emit(state.copyWith(
        status: HomeStatus.loading,
        selectedCategory: 'All',
      ));
    } else {
      // Select new category
      emit(state.copyWith(
        status: HomeStatus.loading,
        selectedCategory: category,
      ));
    }

    // Apply filters on initial feed
    final filtered = _applyClientFilters(_initialFeedRecipes);
    _emitPaginatedState(
      allRecipes: filtered,
      status: HomeStatus.success,
      selectedCategory: state.selectedCategory,
    );
  }

  // Toggle area filter
  void toggleAreaFilter(String area) {
    // Check CURRENT state before any changes
    final bool isCurrentlySelected = state.selectedArea == area;
    final String? newAreaValue = isCurrentlySelected ? null : area;

    emit(state.copyWith(
      status: HomeStatus.loading,
      selectedArea: newAreaValue,
    ));

    // Apply filters on initial feed with the NEW state
    final tempState = state.copyWith(selectedArea: newAreaValue);
    final filtered =
        _applyClientFiltersWithState(_initialFeedRecipes, tempState);

    _emitPaginatedState(
      allRecipes: filtered,
      status: HomeStatus.success,
      selectedArea: newAreaValue,
    );
  }

  // Toggle ingredient filter (uses API)
  Future<void> toggleIngredientFilter(String ingredient) async {
    // Check CURRENT state before any changes
    final bool isCurrentlySelected = state.selectedIngredient == ingredient;

    if (isCurrentlySelected) {
      // Deselect - go back to initial feed with other filters
      emit(state.copyWith(
        status: HomeStatus.loading,
        selectedIngredient: null,
      ));

      final filtered = _applyClientFilters(_initialFeedRecipes);
      _emitPaginatedState(
        allRecipes: filtered,
        status: HomeStatus.success,
        selectedIngredient: null,
      );
    } else {
      // Select - fetch from API
      emit(state.copyWith(status: HomeStatus.loading));
      try {
        final recipes = await _apiService.filterByIngredient(ingredient);
        _emitPaginatedState(
          allRecipes: recipes,
          status: HomeStatus.success,
          selectedCategory: 'All',
          selectedArea: null,
          selectedIngredient: ingredient,
        );
      } catch (e) {
        emit(state.copyWith(
          status: HomeStatus.failure,
          errorMessage: 'Failed to filter by ingredient',
        ));
      }
    }
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
