import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/recipe_model.dart';
import '../models/category_model.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Recipe>> searchRecipes(String query) async {
    final url = '$_baseUrl/search.php?s=$query';
    return _fetchRecipes(url);
  }

  Future<List<Recipe>> getRecipesByFirstLetter(String letter) async {
    final url = '$_baseUrl/search.php?f=$letter';
    return _fetchRecipes(url);
  }

  Future<Recipe> getRecipeById(String id) async {
    final url = '$_baseUrl/lookup.php?i=$id';
    final recipes = await _fetchRecipes(url);
    if (recipes.isNotEmpty) {
      return recipes.first;
    } else {
      throw ApiException('Recipe not found');
    }
  }

  Future<List<Category>> getCategories() async {
    final response = await client.get(Uri.parse('$_baseUrl/categories.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categoriesJson = data['categories'] ?? [];
      return categoriesJson.map((json) => Category.fromJson(json)).toList();
    } else {
      throw ApiException('Failed to load categories');
    }
  }

  Future<List<String>> getAreas() async {
    final response = await client.get(Uri.parse('$_baseUrl/list.php?a=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> areasJson = data['meals'] ?? [];
      return areasJson.map((json) => json['strArea'] as String).toList();
    } else {
      throw ApiException('Failed to load areas');
    }
  }

  Future<List<String>> getIngredients() async {
    final response = await client.get(Uri.parse('$_baseUrl/list.php?i=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> ingredientsJson = data['meals'] ?? [];
      return ingredientsJson
          .map((json) => json['strIngredient'] as String)
          .where((ingredient) => ingredient.isNotEmpty)
          .toList();
    } else {
      throw ApiException('Failed to load ingredients');
    }
  }

  Future<List<Recipe>> filterByCategory(String category) async {
    final url = '$_baseUrl/filter.php?c=$category';
    // Note: Filter endpoint returns abbreviated recipe info (id, name, thumb)
    // We might need to fetch full details for some views, but for list view it's okay.
    // However, Recipe.fromJson expects more fields.
    // We need to handle partial data or fetch details.
    // For now, let's return what we have and handle nulls in Model or fetch details on demand.
    // UPDATE: Recipe.fromJson handles missing fields with empty strings.
    return _fetchRecipes(url);
  }

  Future<List<Recipe>> filterByArea(String area) async {
    final url = '$_baseUrl/filter.php?a=$area';
    return _fetchRecipes(url);
  }

  Future<List<Recipe>> filterByIngredient(String ingredient) async {
    final url = '$_baseUrl/filter.php?i=$ingredient';
    return _fetchRecipes(url);
  }

  // Fetch all recipes by making parallel requests for a-z
  Future<List<Recipe>> getAllRecipes() async {
    final letters = 'abcdefghijklmnopqrstuvwxyz'.split('');

    // Fetch all letters in parallel
    final results = await Future.wait(
      letters.map((letter) => getRecipesByFirstLetter(letter).catchError((e) {
            log('Failed to fetch recipes for letter $letter: $e');
            return <Recipe>[]; // Return empty list on error
          })),
    );

    // Flatten the list of lists into a single list
    final allRecipes = results.expand((recipes) => recipes).toList();

    return allRecipes;
  }

  Future<List<Recipe>> _fetchRecipes(String url) async {
    try {
      final response =
          await client.get(Uri.parse(url)).timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> meals = data['meals'] ?? [];
        return meals.map((json) => Recipe.fromJson(json)).toList();
      } else {
        throw ApiException('Failed to load recipes: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Network error');
    }
  }
}
