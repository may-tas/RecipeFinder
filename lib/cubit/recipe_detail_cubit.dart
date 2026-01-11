import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/recipe_model.dart';
import 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final ApiService _apiService;
  final LocalStorageService _localStorageService;

  RecipeDetailCubit(this._apiService, this._localStorageService)
      : super(const RecipeDetailState());

  Future<void> loadRecipe(String id, {Recipe? placeholder}) async {
    final hasPrefetchedData = placeholder != null &&
        placeholder.instructions.isNotEmpty &&
        placeholder.ingredients.isNotEmpty;

    emit(
      state.copyWith(
        status: hasPrefetchedData
            ? RecipeDetailStatus.success
            : RecipeDetailStatus.loading,
        recipe: placeholder,
        isFavorite: _localStorageService.isFavorite(id),
        isHydrating: !hasPrefetchedData,
      ),
    );

    // Skip network if we already have full data (reduces first navigation lag)
    if (hasPrefetchedData) return;

    try {
      final recipe = await _apiService.getRecipeById(id);
      emit(
        state.copyWith(
          status: RecipeDetailStatus.success,
          recipe: recipe,
          isHydrating: false,
        ),
      );
    } catch (e) {
      log("$e");
      emit(
        state.copyWith(
          status: RecipeDetailStatus.failure,
          errorMessage: "Unknown error occurred, Please try again later",
          isHydrating: false,
        ),
      );
    }
  }

  Future<void> toggleFavorite() async {
    if (state.recipe == null) return;

    await _localStorageService.toggleFavorite(state.recipe!);
    emit(
      state.copyWith(
        isFavorite: _localStorageService.isFavorite(state.recipe!.id),
      ),
    );
  }
}
