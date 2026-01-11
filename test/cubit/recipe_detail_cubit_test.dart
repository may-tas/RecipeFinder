import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:posha/cubit/recipe_detail_cubit.dart';
import 'package:posha/cubit/recipe_detail_state.dart';
import 'package:posha/models/recipe_model.dart';
import 'package:posha/services/api_service.dart';
import 'package:posha/services/local_storage_service.dart';
import 'recipe_detail_cubit_test.mocks.dart';

@GenerateMocks([ApiService, LocalStorageService])
void main() {
  late MockApiService mockApiService;
  late MockLocalStorageService mockLocalStorageService;

  const testRecipe = Recipe(
    id: '52772',
    name: 'Teriyaki Chicken Casserole',
    category: 'Chicken',
    area: 'Japanese',
    instructions: 'Preheat oven to 350° F...',
    thumbUrl: 'thumb_url',
    ingredients: ['soy sauce', 'water'],
    measures: ['3/4 cup', '1/2 cup'],
  );

  setUp(() {
    mockApiService = MockApiService();
    mockLocalStorageService = MockLocalStorageService();
  });

  group('RecipeDetailCubit', () {
    test('loadRecipe emits [loading, success] when successful', () async {
      // Arrange
      when(mockApiService.getRecipeById('52772'))
          .thenAnswer((_) async => testRecipe);
      when(mockLocalStorageService.isFavorite('52772')).thenReturn(false);

      final cubit = RecipeDetailCubit(mockApiService, mockLocalStorageService);

      // Assert
      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<RecipeDetailState>((state) =>
              state.status == RecipeDetailStatus.loading &&
              state.isHydrating == true),
          predicate<RecipeDetailState>((state) =>
              state.status == RecipeDetailStatus.success &&
              state.recipe?.id == '52772' &&
              state.isHydrating == false),
        ]),
      );

      // Act
      await cubit.loadRecipe('52772');
      cubit.close();
    });

    test('loadRecipe emits [success] immediately if placeholder provided',
        () async {
      // Arrange
      when(mockLocalStorageService.isFavorite('52772')).thenReturn(false);
      final cubit = RecipeDetailCubit(mockApiService, mockLocalStorageService);

      // Assert
      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<RecipeDetailState>((state) =>
              state.status == RecipeDetailStatus.success &&
              state.recipe?.id == '52772'),
        ]),
      );

      // Act
      await cubit.loadRecipe('52772', placeholder: testRecipe);
      verifyNever(mockApiService.getRecipeById(any));
      cubit.close();
    });

    test('loadRecipe emits [loading, failure] on error', () async {
      // Arrange
      when(mockApiService.getRecipeById('99999'))
          .thenAnswer((_) => Future.error(Exception('Recipe not found')));
      when(mockLocalStorageService.isFavorite('99999')).thenReturn(false);

      final cubit = RecipeDetailCubit(mockApiService, mockLocalStorageService);

      // Assert
      expectLater(
        cubit.stream,
        emitsInOrder([
          predicate<RecipeDetailState>(
              (state) => state.status == RecipeDetailStatus.loading),
          predicate<RecipeDetailState>((state) =>
              state.status == RecipeDetailStatus.failure &&
              state.errorMessage.isNotEmpty),
        ]),
      );

      // Act
      await cubit.loadRecipe('99999');
      cubit.close();
    });

    test('toggleFavorite toggles status', () async {
      // Arrange
      when(mockApiService.getRecipeById('52772'))
          .thenAnswer((_) async => testRecipe);
      when(mockLocalStorageService.isFavorite('52772')).thenReturn(false);
      when(mockLocalStorageService.toggleFavorite(testRecipe))
          .thenAnswer((_) async {});

      final cubit = RecipeDetailCubit(mockApiService, mockLocalStorageService);

      // Load initial state
      await cubit.loadRecipe('52772');

      // Update mock to return true (simulating successful toggle effect)
      when(mockLocalStorageService.isFavorite('52772')).thenReturn(true);

      // Act
      await cubit.toggleFavorite();

      // Assert
      expect(cubit.state.isFavorite, true);
      verify(mockLocalStorageService.toggleFavorite(testRecipe)).called(1);
      cubit.close();
    });
  });
}
