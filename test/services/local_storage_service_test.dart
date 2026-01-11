import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:posha/models/recipe_model.dart';
import 'package:posha/services/local_storage_service.dart';

import 'local_storage_service_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<Box<Recipe>>(as: #MockRecipeBox)])
void main() {
  late LocalStorageService service;
  late MockRecipeBox mockBox;

  const testRecipe = Recipe(
    id: '1',
    name: 'Test Recipe',
    category: 'Test',
    area: 'Test',
    instructions: 'Test instructions',
    thumbUrl: 'http://test.com/1.jpg',
    ingredients: ['ingredient1'],
    measures: ['1 cup'],
  );

  setUp(() {
    mockBox = MockRecipeBox();
    service = LocalStorageService(testBox: mockBox);
  });

  group('LocalStorageService', () {
    test('getFavorites returns list of recipes', () {
      // Arrange
      when(mockBox.values).thenReturn([testRecipe]);

      // Act
      final result = service.getFavorites();

      // Assert
      expect(result.length, 1);
      expect(result.first, testRecipe);
      verify(mockBox.values).called(1);
    });

    test('isFavorite returns true when key exists', () {
      // Arrange
      when(mockBox.containsKey('1')).thenReturn(true);

      // Act
      final result = service.isFavorite('1');

      // Assert
      expect(result, true);
      verify(mockBox.containsKey('1')).called(1);
    });

    test('isFavorite returns false when key does not exist', () {
      // Arrange
      when(mockBox.containsKey('1')).thenReturn(false);

      // Act
      final result = service.isFavorite('1');

      // Assert
      expect(result, false);
      verify(mockBox.containsKey('1')).called(1);
    });

    test('toggleFavorite adds recipe if not favorite', () async {
      // Arrange
      when(mockBox.containsKey('1')).thenReturn(false);
      when(mockBox.put('1', testRecipe)).thenAnswer((_) async {});
      when(mockBox.values).thenReturn([testRecipe]);

      // Act
      await service.toggleFavorite(testRecipe);

      // Assert
      verify(mockBox.put('1', testRecipe)).called(1);
      verifyNever(mockBox.delete(any));
      expect(service.favoritesChanged.value, 1);
    });

    test('toggleFavorite removes recipe if already favorite', () async {
      // Arrange
      when(mockBox.containsKey('1')).thenReturn(true);
      when(mockBox.delete('1')).thenAnswer((_) async {});
      when(mockBox.values).thenReturn([]);

      // Act
      await service.toggleFavorite(testRecipe);

      // Assert
      verify(mockBox.delete('1')).called(1);
      verifyNever(mockBox.put(any, any));
      expect(service.favoritesChanged.value, 1);
    });
  });
}
