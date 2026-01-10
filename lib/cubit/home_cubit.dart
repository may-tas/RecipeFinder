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
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
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

  void loadMore() {
    if (state.hasReachedMax || state.status != HomeStatus.success) return;

    final currentLength = state.recipes.length;
    final nextChunk = state.allRecipes
        .skip(currentLength)
        .take(_pageSize)
        .toList();

    if (nextChunk.isEmpty) {
      emit(state.copyWith(hasReachedMax: true));
    } else {
      emit(
        state.copyWith(
          recipes: List.of(state.recipes)..addAll(nextChunk),
          hasReachedMax:
              (state.recipes.length + nextChunk.length) >=
              state.allRecipes.length,
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
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
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
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> filterByArea(String area) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final recipes = await _apiService.filterByArea(area);
      _emitPaginatedState(
        allRecipes: recipes,
        status: HomeStatus.success,
        selectedCategory: 'All', // Reset category filter
        selectedArea: area,
      );
    } catch (e) {
      emit(
        state.copyWith(status: HomeStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  void toggleViewMode() {
    emit(state.copyWith(isGridView: !state.isGridView));
  }
}
