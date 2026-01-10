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
      // Load initial recipes (e.g., 'c' for Chicken/Cake)
      final recipes = await _apiService.getRecipesByFirstLetter('c');

      _initialFeedRecipes = recipes;

      _emitPaginatedState(
        allRecipes: recipes,
        categories: categories,
        areas: areas,
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
    required HomeStatus status,
    String? selectedCategory,
    String? selectedArea,
  }) {
    final initialChunk = allRecipes.take(_pageSize).toList();
    emit(
      state.copyWith(
        status: status,
        allRecipes: allRecipes,
        recipes: initialChunk,
        hasReachedMax: initialChunk.length >= allRecipes.length,
        categories: categories ?? state.categories,
        areas: areas ?? state.areas,
        selectedCategory: selectedCategory ?? state.selectedCategory,
        selectedArea: selectedArea ?? state.selectedArea,
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

  void toggleViewMode() {
    emit(state.copyWith(isGridView: !state.isGridView));
  }
}
