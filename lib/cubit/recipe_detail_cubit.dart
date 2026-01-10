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
    emit(
      state.copyWith(
        status: RecipeDetailStatus.loading,
        recipe: placeholder,
        isFavorite: _localStorageService.isFavorite(id),
      ),
    );

    try {
      final recipe = await _apiService.getRecipeById(id);
      emit(state.copyWith(status: RecipeDetailStatus.success, recipe: recipe));
    } catch (e) {
      log("$e");
      emit(
        state.copyWith(
          status: RecipeDetailStatus.failure,
          errorMessage: "Unknown error occurred, Please try again later",
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
