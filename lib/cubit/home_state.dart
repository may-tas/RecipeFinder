import 'package:equatable/equatable.dart';
import '../models/recipe_model.dart';
import '../models/category_model.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<Recipe> recipes; // Currently displayed recipes
  final List<Recipe>
      allRecipes; // All fetched recipes (for client-side pagination)
  final bool hasReachedMax;
  final List<Category> categories;
  final List<String> areas;
  final List<String> ingredients;
  final String selectedCategory; // "All" or specific category
  final String? selectedArea;
  final String? selectedIngredient;
  final bool isGridView;
  final String errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.recipes = const [],
    this.allRecipes = const [],
    this.hasReachedMax = false,
    this.categories = const [],
    this.areas = const [],
    this.ingredients = const [],
    this.selectedCategory = 'All',
    this.selectedArea,
    this.selectedIngredient,
    this.isGridView = true,
    this.errorMessage = '',
    this.isLoadingMore = false,
  });

  final bool isLoadingMore;

  HomeState copyWith({
    HomeStatus? status,
    List<Recipe>? recipes,
    List<Recipe>? allRecipes,
    bool? hasReachedMax,
    List<Category>? categories,
    List<String>? areas,
    List<String>? ingredients,
    String? selectedCategory,
    Object? selectedArea = _undefined,
    Object? selectedIngredient = _undefined,
    bool? isGridView,
    String? errorMessage,
    bool? isLoadingMore,
  }) {
    return HomeState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      allRecipes: allRecipes ?? this.allRecipes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      categories: categories ?? this.categories,
      areas: areas ?? this.areas,
      ingredients: ingredients ?? this.ingredients,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedArea: selectedArea == _undefined
          ? this.selectedArea
          : selectedArea as String?,
      selectedIngredient: selectedIngredient == _undefined
          ? this.selectedIngredient
          : selectedIngredient as String?,
      isGridView: isGridView ?? this.isGridView,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recipes,
        allRecipes,
        hasReachedMax,
        categories,
        areas,
        ingredients,
        selectedCategory,
        selectedArea,
        selectedIngredient,
        isGridView,
        errorMessage,
        isLoadingMore,
      ];
}

// Sentinel value for optional nullable parameters
const Object _undefined = Object();
