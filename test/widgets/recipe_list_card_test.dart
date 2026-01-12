import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posha/models/recipe_model.dart';
import 'package:posha/utils/size_config.dart';
import 'package:posha/views/widgets/common/recipe_list_card.dart';

void main() {
  const testRecipe = Recipe(
    id: '1',
    name: 'Test Recipe',
    category: 'Chicken',
    area: 'Japanese',
    instructions: 'Test instructions for the recipe',
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
        body: Builder(
          builder: (context) {
            // Initialize SizeConfig for testing
            SizeConfig().init(context);
            return RecipeListCard(
              recipe: recipe ?? testRecipe,
              isFavorite: isFavorite,
              onFavoriteToggle: onFavoriteToggle,
            );
          },
        ),
      ),
    );
  }

  group('RecipeListCard Widget', () {
    testWidgets('should display recipe name, category, area and instructions',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.text('Chicken • Japanese'), findsOneWidget);
      expect(find.text('Test instructions for the recipe'), findsOneWidget);
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

    testWidgets('should have correct container height', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert - height should be 25% of screen width (800 * 0.25 = 200)
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byType(Row),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxHeight, 200.0);
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

    testWidgets('should truncate long text correctly', (tester) async {
      // Arrange
      const longTextRecipe = Recipe(
        id: '2',
        name: 'Very Long Recipe Name That Should Definitely Be Truncated',
        category: 'Test Category',
        area: 'Test Area',
        instructions:
            'Very long instructions that should also be truncated with ellipsis',
        thumbUrl: 'https://test.com/image.jpg',
        ingredients: [],
        measures: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(recipe: longTextRecipe));

      // Assert
      final nameText = tester.widget<Text>(
        find.text('Very Long Recipe Name That Should Definitely Be Truncated'),
      );
      expect(nameText.maxLines, 1);
      expect(nameText.overflow, TextOverflow.ellipsis);

      final instructionsText = tester.widget<Text>(
        find.text(
            'Very long instructions that should also be truncated with ellipsis'),
      );
      expect(instructionsText.maxLines, 1);
      expect(instructionsText.overflow, TextOverflow.ellipsis);
    });

    testWidgets('should not display category/area if empty', (tester) async {
      // Arrange
      const emptyRecipe = Recipe(
        id: '3',
        name: 'Test',
        category: '',
        area: '',
        instructions: '',
        thumbUrl: 'https://test.com/image.jpg',
        ingredients: [],
        measures: [],
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(recipe: emptyRecipe));

      // Assert
      expect(find.text(' • '), findsNothing);
    });

    testWidgets('should have CachedNetworkImage widget', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });
  });
}
