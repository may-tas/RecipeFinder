import 'package:flutter_test/flutter_test.dart';
import 'package:posha/models/recipe_model.dart';

void main() {
  group('Recipe Model - fromJson', () {
    test('should correctly deserialize from JSON', () {
      // Arrange
      final json = {
        'idMeal': '52772',
        'strMeal': 'Teriyaki Chicken Casserole',
        'strCategory': 'Chicken',
        'strArea': 'Japanese',
        'strInstructions':
            'Preheat oven to 350° F. Spray a 9x13-inch baking pan with non-stick spray.',
        'strMealThumb':
            'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
        'strYoutube': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
        'strIngredient1': 'soy sauce',
        'strIngredient2': 'water',
        'strIngredient3': 'brown sugar',
        'strIngredient4': '',
        'strMeasure1': '3/4 cup',
        'strMeasure2': '1/2 cup',
        'strMeasure3': '1/4 cup',
        'strMeasure4': '',
      };

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.id, '52772');
      expect(recipe.name, 'Teriyaki Chicken Casserole');
      expect(recipe.category, 'Chicken');
      expect(recipe.area, 'Japanese');
      expect(recipe.instructions, contains('Preheat oven'));
      expect(recipe.thumbUrl,
          'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg');
      expect(recipe.videoUrl, 'https://www.youtube.com/watch?v=4aZr5hZXP_s');
      expect(recipe.ingredients.length, 3);
      expect(recipe.ingredients, ['soy sauce', 'water', 'brown sugar']);
      expect(recipe.measures.length, 3);
      expect(recipe.measures, ['3/4 cup', '1/2 cup', '1/4 cup']);
    });

    test('should handle empty ingredients correctly', () {
      // Arrange
      final json = {
        'idMeal': '1',
        'strMeal': 'Test Recipe',
        'strCategory': 'Test',
        'strArea': 'Test',
        'strInstructions': 'Test instructions',
        'strMealThumb': 'http://test.com/image.jpg',
        'strIngredient1': 'ingredient1',
        'strIngredient2': '',
        'strIngredient3': '   ',
        'strIngredient4': null,
        'strMeasure1': '1 cup',
        'strMeasure2': '',
        'strMeasure3': '',
        'strMeasure4': '',
      };

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.ingredients.length, 1);
      expect(recipe.ingredients, ['ingredient1']);
      expect(recipe.measures.length, 1);
    });

    test('should handle missing optional fields', () {
      // Arrange
      final json = {
        'idMeal': '1',
        'strMeal': 'Test Recipe',
        'strCategory': 'Test',
        'strArea': 'Test',
        'strInstructions': 'Test instructions',
        'strMealThumb': 'http://test.com/image.jpg',
        // No strYoutube field
      };

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.videoUrl, isNull);
      expect(recipe.ingredients, isEmpty);
    });

    test('should handle all 20 ingredient slots', () {
      // Arrange
      final json = <String, dynamic>{
        'idMeal': '1',
        'strMeal': 'Test Recipe',
        'strCategory': 'Test',
        'strArea': 'Test',
        'strInstructions': 'Test',
        'strMealThumb': 'http://test.com/image.jpg',
      };

      // Add 20 ingredients
      for (int i = 1; i <= 20; i++) {
        json['strIngredient$i'] = 'ingredient$i';
        json['strMeasure$i'] = '${i}kg';
      }

      // Act
      final recipe = Recipe.fromJson(json);

      // Assert
      expect(recipe.ingredients.length, 20);
      expect(recipe.measures.length, 20);
      expect(recipe.ingredients.first, 'ingredient1');
      expect(recipe.ingredients.last, 'ingredient20');
      expect(recipe.measures.first, '1kg');
      expect(recipe.measures.last, '20kg');
    });
  });

  group('Recipe Model - toJson', () {
    test('should correctly serialize to JSON', () {
      // Arrange
      const recipe = Recipe(
        id: '52772',
        name: 'Teriyaki Chicken Casserole',
        category: 'Chicken',
        area: 'Japanese',
        instructions: 'Preheat oven to 350° F.',
        thumbUrl:
            'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
        videoUrl: 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
        ingredients: ['soy sauce', 'water'],
        measures: ['3/4 cup', '1/2 cup'],
      );

      // Act
      final json = recipe.toJson();

      // Assert
      expect(json['idMeal'], '52772');
      expect(json['strMeal'], 'Teriyaki Chicken Casserole');
      expect(json['strCategory'], 'Chicken');
      expect(json['strArea'], 'Japanese');
      expect(json['strInstructions'], 'Preheat oven to 350° F.');
      expect(json['strMealThumb'],
          'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg');
      expect(json['strYoutube'], 'https://www.youtube.com/watch?v=4aZr5hZXP_s');
    });

    test('should handle null videoUrl', () {
      // Arrange
      const recipe = Recipe(
        id: '1',
        name: 'Test',
        category: 'Test',
        area: 'Test',
        instructions: 'Test',
        thumbUrl: 'test.jpg',
        ingredients: [],
        measures: [],
      );

      // Act
      final json = recipe.toJson();

      // Assert
      expect(json['strYoutube'], isNull);
    });
  });

  group('Recipe Model - Equatable', () {
    test('should be equal when all properties are the same', () {
      // Arrange
      const recipe1 = Recipe(
        id: '1',
        name: 'Test',
        category: 'Test',
        area: 'Test',
        instructions: 'Test',
        thumbUrl: 'test.jpg',
        ingredients: ['ing1'],
        measures: ['1 cup'],
      );

      const recipe2 = Recipe(
        id: '1',
        name: 'Test',
        category: 'Test',
        area: 'Test',
        instructions: 'Test',
        thumbUrl: 'test.jpg',
        ingredients: ['ing1'],
        measures: ['1 cup'],
      );

      // Assert
      expect(recipe1, equals(recipe2));
      expect(recipe1.hashCode, equals(recipe2.hashCode));
    });

    test('should not be equal when properties differ', () {
      // Arrange
      const recipe1 = Recipe(
        id: '1',
        name: 'Test',
        category: 'Test',
        area: 'Test',
        instructions: 'Test',
        thumbUrl: 'test.jpg',
        ingredients: [],
        measures: [],
      );

      const recipe2 = Recipe(
        id: '2',
        name: 'Test',
        category: 'Test',
        area: 'Test',
        instructions: 'Test',
        thumbUrl: 'test.jpg',
        ingredients: [],
        measures: [],
      );

      // Assert
      expect(recipe1, isNot(equals(recipe2)));
    });
  });
}
