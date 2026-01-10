/// Application string constants for localization and consistency
class AppStrings {
  AppStrings._();

  // App
  static const String appTitle = 'Recipe Finder';

  // Navigation
  static const String navHome = 'Home';
  static const String navFavorites = 'Favorites';

  // Home Screen
  static const String homeTitle = 'Discover Recipes';
  static const String categoryAll = 'All';

  // Favorites Screen
  static const String favoritesTitle = 'My Favorites';
  static const String favoritesEmpty = 'No favorites yet';
  static const String favoritesEmptyDescription =
      'Browse recipes and tap the heart to save your favorites';
  static const String browseRecipes = 'Browse Recipes';
  static const String removedFromFavorites = 'Removed from favorites';
  static const String undo = 'Undo';

  // Recipe List
  static const String noRecipesFound = 'No recipes found';
  static const String tryAdjustingFilters = 'Try adjusting your filters';
  static const String failedToLoadRecipes = 'Failed to load recipes';
  static const String retry = 'Retry';

  // Recipe Detail
  static const String recipeNotFound = 'Recipe not found';
  static const String tabOverview = 'Overview';
  static const String tabIngredients = 'Ingredients';
  static const String tabInstructions = 'Instructions';

  // Recipe Overview
  static const String watchHowToMake = 'Watch How to Make';
  static const String aboutThisRecipe = 'About this Recipe';
  static const String labelCategory = 'Category';
  static const String labelCuisine = 'Cuisine';

  // Recipe Ingredients
  static String ingredientsCount(int count) => 'Ingredients ($count)';

  // Recipe Instructions
  static String instructionsSteps(int count) => 'Instructions ($count steps)';

  // Placeholder Strings
  static const String placeholderRecipeName = 'Loading Recipe Name';
  static const String placeholderCategory = 'Category';
  static const String placeholderArea = 'Area';
  static const String placeholderCategoryName = 'Category Name';

  // Filter Strings
  static const String filters = "Filters";
}
