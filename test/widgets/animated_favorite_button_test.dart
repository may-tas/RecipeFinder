import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posha/constants/app_colors.dart';
import 'package:posha/views/widgets/common/animated_favorite_button.dart';

void main() {
  Widget createWidgetUnderTest({
    bool isFavorite = false,
    VoidCallback? onTap,
    double size = 44,
    double iconSize = 22,
    bool showBorder = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedFavoriteButton(
          isFavorite: isFavorite,
          onTap: onTap,
          size: size,
          iconSize: iconSize,
          showBorder: showBorder,
        ),
      ),
    );
  }

  group('AnimatedFavoriteButton Widget', () {
    testWidgets('should display favorite icon when isFavorite is true',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: true));

      // Assert
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsNothing);
    });

    testWidgets('should display favorite_border icon when isFavorite is false',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: false));

      // Assert
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsNothing);
    });

    testWidgets('should call onTap callback when tapped', (tester) async {
      // Arrange
      bool wasTapped = false;
      await tester.pumpWidget(createWidgetUnderTest(
        onTap: () => wasTapped = true,
      ));

      // Act
      await tester.tap(find.byType(AnimatedFavoriteButton));
      await tester.pump();

      // Assert
      expect(wasTapped, true);
    });

    testWidgets('should animate when isFavorite changes', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: false));
      await tester.pump();

      // Act - Change isFavorite to true
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: true));

      // Pump a few frames to see animation
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 150));

      // Assert - Icon should have changed
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('should use custom size when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(size: 60));

      // Assert
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.favorite_border),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(container.constraints?.maxWidth, 60);
      expect(container.constraints?.maxHeight, 60);
    });

    testWidgets('should use custom icon size when provided', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(iconSize: 30));

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
      expect(icon.size, 30);
    });

    testWidgets('should show border when showBorder is true', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(showBorder: true));

      // Assert
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.favorite_border),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('should not show border when showBorder is false',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(showBorder: false));

      // Assert
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.favorite_border),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
    });

    testWidgets('should have circular shape', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final container = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.favorite_border),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('should display red color for favorite icon', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: true));

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
      expect(icon.color, AppColors.accentRed);
    });

    testWidgets('should display white color for unfavorite icon',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: false));

      // Assert
      final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
      expect(icon.color, AppColors.white);
    });

    testWidgets('should have GestureDetector wrapping the widget',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('should complete animation cycle', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: false));

      // Act - Toggle favorite
      await tester.pumpWidget(createWidgetUnderTest(isFavorite: true));

      // Pump through entire animation (300ms)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Assert - Animation should complete
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });
  });
}
