import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:posha/models/recipe_model.dart';
import 'package:posha/models/category_model.dart';
import 'package:posha/services/api_service.dart';
import 'api_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    apiService = ApiService(client: mockClient);
  });

  group('ApiService - searchRecipes', () {
    test('should return list of recipes when API call is successful', () async {
      // Arrange
      const responseBody = '''
      {
        "meals": [
          {
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken Casserole",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "Preheat oven to 350° F...",
            "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            "strIngredient1": "soy sauce",
            "strMeasure1": "3/4 cup"
          }
        ]
      }
      ''';
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/search.php?s=chicken')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await apiService.searchRecipes('chicken');

      // Assert
      expect(result, isA<List<Recipe>>());
      expect(result.length, 1);
      expect(result[0].id, '52772');
      expect(result[0].name, 'Teriyaki Chicken Casserole');
      expect(result[0].category, 'Chicken');
      verify(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/search.php?s=chicken')))
          .called(1);
    });

    test('should return empty list when no recipes found', () async {
      // Arrange
      const responseBody = '{"meals": null}';
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/search.php?s=xyz')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await apiService.searchRecipes('xyz');

      // Assert
      expect(result, isEmpty);
    });

    test('should throw ApiException when API call fails', () async {
      // Arrange
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/search.php?s=test')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(
          () => apiService.searchRecipes('test'), throwsA(isA<ApiException>()));
    });
  });

  group('ApiService - getRecipeById', () {
    test('should return a recipe when API call is successful', () async {
      // Arrange
      const responseBody = '''
      {
        "meals": [
          {
            "idMeal": "52772",
            "strMeal": "Teriyaki Chicken Casserole",
            "strCategory": "Chicken",
            "strArea": "Japanese",
            "strInstructions": "Preheat oven to 350° F...",
            "strMealThumb": "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            "strIngredient1": "soy sauce",
            "strMeasure1": "3/4 cup"
          }
        ]
      }
      ''';
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/lookup.php?i=52772')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await apiService.getRecipeById('52772');

      // Assert
      expect(result, isA<Recipe>());
      expect(result.id, '52772');
      expect(result.name, 'Teriyaki Chicken Casserole');
    });

    test('should throw ApiException when recipe not found', () async {
      // Arrange
      const responseBody = '{"meals": null}';
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/lookup.php?i=99999')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act & Assert
      expect(() => apiService.getRecipeById('99999'),
          throwsA(isA<ApiException>()));
    });
  });

  group('ApiService - getCategories', () {
    test('should return list of categories when API call is successful',
        () async {
      // Arrange
      const responseBody = '''
      {
        "categories": [
          {
            "idCategory": "1",
            "strCategory": "Beef",
            "strCategoryThumb": "https://www.themealdb.com/images/category/beef.png",
            "strCategoryDescription": "Beef is the culinary name for meat from cattle."
          }
        ]
      }
      ''';
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/categories.php')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await apiService.getCategories();

      // Assert
      expect(result, isA<List<Category>>());
      expect(result.length, 1);
      expect(result[0].name, 'Beef');
    });

    test('should throw ApiException when API call fails', () async {
      // Arrange
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/categories.php')))
          .thenAnswer((_) async => http.Response('Server Error', 500));

      // Act & Assert
      expect(() => apiService.getCategories(), throwsA(isA<ApiException>()));
    });
  });

  group('ApiService - getAreas', () {
    test('should return list of areas when API call is successful', () async {
      // Arrange
      const responseBody = '''
      {
        "meals": [
          {"strArea": "American"},
          {"strArea": "British"},
          {"strArea": "Canadian"}
        ]
      }
      ''';
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/list.php?a=list')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await apiService.getAreas();

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, 3);
      expect(result, containsAll(['American', 'British', 'Canadian']));
    });

    test('should throw ApiException when API call fails', () async {
      // Arrange
      when(mockClient.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/list.php?a=list')))
          .thenAnswer((_) async => http.Response('Error', 500));

      // Act & Assert
      expect(() => apiService.getAreas(), throwsA(isA<ApiException>()));
    });
  });

  group('ApiService - getAllRecipes', () {
    test('should return recipes from multiple letters', () async {
      // Arrange - Mock responses for a few letters
      const responseA = '''
      {
        "meals": [
          {
            "idMeal": "1",
            "strMeal": "Apple Pie",
            "strCategory": "Dessert",
            "strArea": "American",
            "strInstructions": "Make pie...",
            "strMealThumb": "https://example.com/apple.jpg",
            "strIngredient1": "Apple",
            "strMeasure1": "3"
          }
        ]
      }
      ''';

      // Mock all 26 letters - return empty for most, one recipe for 'a'
      for (var i = 0; i < 26; i++) {
        final letter = String.fromCharCode(97 + i); // a-z
        final url = Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/search.php?f=$letter');
        if (letter == 'a') {
          when(mockClient.get(url))
              .thenAnswer((_) async => http.Response(responseA, 200));
        } else {
          when(mockClient.get(url))
              .thenAnswer((_) async => http.Response('{"meals": null}', 200));
        }
      }

      // Act
      final result = await apiService.getAllRecipes();

      // Assert
      expect(result, isA<List<Recipe>>());
      expect(result.length, 1);
      expect(result[0].name, 'Apple Pie');
    });
  });
}
