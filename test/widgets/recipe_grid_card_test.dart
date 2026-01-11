import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posha/constants/app_colors.dart';
import 'package:posha/models/recipe_model.dart';
import 'package:posha/views/widgets/common/recipe_grid_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  const testRecipe = Recipe(
    id: '1',
    name: 'Test Recipe',
    category: 'Chicken',
    area: 'Japanese',
    instructions: 'Test instructions',
    thumbUrl: 'https://test.com/image.jpg',
    ingredients: ['ingredient1'],
    measures: ['1 cup'],
  );

  Widget createWidgetUnderTest({
    Recipe? recipe,
    bool isFavorite = false,
    VoidCallback? onFavoriteToggle,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: RecipeGridCard(
          recipe: recipe ?? testRecipe,
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
      ),
    );
  }

  group('RecipeGridCard Widget', () {
    testWidgets('should display recipe name and category', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('Chicken • Japanese'), findsOneWidget);
    });

    testWidgets('should display favorite icon when isFavorite is true',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: true));

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should display favorite_border icon when isFavorite is false',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: false));

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('should call onFavoriteToggle when favorite button is tapped',
        (tester) async {
      // Arrange
      bool wasCalled = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onFavoriteToggle: () => wasCalled = true,
      ));

      // Act
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();

      // Assert
      expect(wasCalled, true);
    });

    testWidgets('should display hero widget with correct tag', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final heroFinder = find.byType(Hero);
      expect(heroFinder, findsOneWidget);

      final hero = tester.widget<Hero>(heroFinder);
      expect(hero.tag, 'recipe_image_1');
    });

    testWidgets('should have CachedNetworkImage widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('should have AnimatedContainer with transform', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(container.transform, isNotNull);
    });

    testWidgets('should have correct styling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.darkGrey);
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(decoration.border, isNotNull);
    });

    testWidgets('should display correct text with long recipe name',
        (tester) async {
      // Arrange
      const longNameRecipe = Recipe(
        id: '2',
        name: 'Very Long Recipe Name That Should Be Truncated With Ellipsis',
        category: 'Test',
        area: 'Test',
        instructions: 'Test',
        thumbUrl: 'https://test.com/image.jpg',
        ingredients: [],
        measures: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(recipe: longNameRecipe));

      // Assert
      final textWidget = tester.widget<Text>(
        find.text(
            'Very Long Recipe Name That Should Be Truncated With Ellipsis'),
      );
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
