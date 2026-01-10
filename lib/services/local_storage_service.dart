import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe_model.dart';

class LocalStorageService {
  static const String _favoritesBoxName = 'favorites';

  Future<void> init() async {
    Hive.registerAdapter(RecipeAdapter());
    await Hive.openBox<Recipe>(_favoritesBoxName);
  }

  Box<Recipe> get _favoritesBox => Hive.box<Recipe>(_favoritesBoxName);

  List<Recipe> getFavorites() {
    return _favoritesBox.values.toList();
  }

  bool isFavorite(String id) {
    return _favoritesBox.containsKey(id);
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    if (isFavorite(recipe.id)) {
      await _favoritesBox.delete(recipe.id);
    } else {
      await _favoritesBox.put(recipe.id, recipe);
    }
  }
}
