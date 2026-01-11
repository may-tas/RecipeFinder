import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:posha/cubit/home_cubit.dart';
import 'package:posha/cubit/home_state.dart';
import 'package:posha/models/recipe_model.dart';
import 'package:posha/models/category_model.dart';
import 'package:posha/services/api_service.dart';
import 'home_cubit_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;

  final testRecipes = [
    const Recipe(
      id: '1',
      name: 'Chicken Curry',
      category: 'Chicken',
      area: 'Indian',
      instructions: 'Cook it',
      thumbUrl: 'url1',
      ingredients: ['chicken', 'curry'],
      measures: ['1kg', '2 tbsp'],
    ),
  ];

  final testCategories = [
    const Category(
      id: '1',
      name: 'Chicken',
      thumbUrl: 'thumb1',
      description: 'Chicken dishes',
    ),
  ];

  final testAreas = ['Indian'];

  setUp(() {
    mockApiService = MockApiService();
  });

  group('HomeCubit', () {
    test('emits success state with data after loading', () async {
      // Arrange
      when(mockApiService.getAllRecipes()).thenAnswer((_) async => testRecipes);
      when(mockApiService.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockApiService.getAreas()).thenAnswer((_) async => testAreas);
      when(mockApiService.getIngredients())
          .thenAnswer((_) async => ['chicken']);

      // Act
      final cubit = HomeCubit(mockApiService);

      // Assert
      // Listen immediately
      await expectLater(
        cubit.stream,
        emits(
          predicate<HomeState>((state) =>
              state.status == HomeStatus.success &&
              state.recipes.length == 1 &&
              state.categories.length == 1),
        ),
      );
      cubit.close();
    });

    test('emits failure state on API error', () async {
      // Arrange
      // Use Future.error so the error happens asynchronously during the await chain
      when(mockApiService.getCategories())
          .thenAnswer((_) => Future.error(Exception('Network error')));
      when(mockApiService.getAreas()).thenAnswer((_) async => []);
      when(mockApiService.getIngredients()).thenAnswer((_) async => []);
      when(mockApiService.getAllRecipes()).thenAnswer((_) async => []);

      // Act
      final cubit = HomeCubit(mockApiService);

      // Assert
      await expectLater(
        cubit.stream,
        emits(
          predicate<HomeState>((state) =>
              state.status == HomeStatus.failure &&
              state.errorMessage.isNotEmpty),
        ),
      );
      cubit.close();
    });

    test('toggleViewMode toggles isGridView', () async {
      // Arrange
      when(mockApiService.getAllRecipes()).thenAnswer((_) async => testRecipes);
      when(mockApiService.getCategories())
          .thenAnswer((_) async => testCategories);
      when(mockApiService.getAreas()).thenAnswer((_) async => testAreas);
      when(mockApiService.getIngredients()).thenAnswer((_) async => []);

      final cubit = HomeCubit(mockApiService);

      // Wait for success so loading doesn't interfere
      await cubit.stream
          .firstWhere((state) => state.status != HomeStatus.loading);

      // Act
      cubit.toggleViewMode();

      // Assert
      expect(cubit.state.isGridView, false);
      cubit.close();
    });
  });
}
