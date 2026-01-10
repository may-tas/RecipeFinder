import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'recipe_model.g.dart';

@HiveType(typeId: 0)
class Recipe extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String area;
  @HiveField(4)
  final String instructions;
  @HiveField(5)
  final String thumbUrl;
  @HiveField(6)
  final String? videoUrl;
  @HiveField(7)
  final List<String> ingredients;
  @HiveField(8)
  final List<String> measures;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    this.videoUrl,
    required this.ingredients,
    required this.measures,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add(ingredient);
        measures.add(measure ?? '');
      }
    }

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbUrl: json['strMealThumb'] ?? '',
      videoUrl: json['strYoutube'],
      ingredients: ingredients,
      measures: measures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbUrl,
      'strYoutube': videoUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        area,
        instructions,
        thumbUrl,
        videoUrl,
        ingredients,
        measures
      ];
}
