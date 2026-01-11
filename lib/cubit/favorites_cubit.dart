import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/recipe_model.dart';
import '../services/local_storage_service.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final LocalStorageService _localStorageService;

  FavoritesCubit(this._localStorageService) : super(const FavoritesState()) {
    loadFavorites();
    _localStorageService.favoritesChanged.addListener(_onFavoritesChanged);
  }

  void _onFavoritesChanged() {
    loadFavorites();
  }

  @override
  Future<void> close() {
    _localStorageService.favoritesChanged.removeListener(_onFavoritesChanged);
    return super.close();
  }

  void loadFavorites() {
    emit(state.copyWith(status: FavoritesStatus.loading));
    try {
      final favorites = _localStorageService.getFavorites();
      emit(
        state.copyWith(status: FavoritesStatus.success, favorites: favorites),
      );
    } catch (e) {
      log("$e");
      emit(state.copyWith(status: FavoritesStatus.failure));
    }
  }

  Future<void> removeFavorite(String id) async {
    final recipe = state.favorites.firstWhereOrNull((r) => r.id == id);
    final updatedFavorites = state.favorites.where((r) => r.id != id).toList();
    emit(state.copyWith(favorites: updatedFavorites));
    // Also remove from storage
    if (recipe != null) {
      await _localStorageService.toggleFavorite(recipe);
    }
  }

  Future<void> addFavorite(Recipe recipe) async {
    final updatedFavorites = [...state.favorites, recipe];
    emit(state.copyWith(favorites: updatedFavorites));
    await _localStorageService.toggleFavorite(recipe);
  }

  void refresh() {
    loadFavorites();
  }
}
