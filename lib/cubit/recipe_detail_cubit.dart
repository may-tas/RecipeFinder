import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/recipe_model.dart';
import 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  RecipeDetailCubit(this._apiService, this._localStorageService) : super(const RecipeDetailState());

  Future<void> loadRecipe(String id, {Recipe? placeholder}) async {
    emit(state.copyWith(
      status: RecipeDetailStatus.loading,
      recipe: placeholder,
      isFavorite: _localStorageService.isFavorite(id),
    ));

    try {
      final recipe = await _apiService.getRecipeById(id);
      emit(state.copyWith(
        status: RecipeDetailStatus.success,
        recipe: recipe,
      ));
    } catch (e) {
      if (placeholder != null) {
        // If API fails but we have placeholder (e.g. from list), check if we can show it
        // But usually we want full details.
        // Let's keep showing placeholder if available but mark as failure?
        // Or better, just show error.
      }
      emit(state.copyWith(status: RecipeDetailStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> toggleFavorite() async {
    if (state.recipe == null) return;
    
    await _localStorageService.toggleFavorite(state.recipe!);
    emit(state.copyWith(isFavorite: _localStorageService.isFavorite(state.recipe!.id)));
  }
}
