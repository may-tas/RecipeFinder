import 'package:equatable/equatable.dart';
import '../models/recipe_model.dart';

enum RecipeDetailStatus { initial, loading, success, failure }

class RecipeDetailState extends Equatable {
  final RecipeDetailStatus status;
  final Recipe? recipe;
  final bool isFavorite;
  final String errorMessage;

  const RecipeDetailState({
    this.status = RecipeDetailStatus.initial,
    this.recipe,
    this.isFavorite = false,
    this.errorMessage = '',
  });

  RecipeDetailState copyWith({
    RecipeDetailStatus? status,
    Recipe? recipe,
    bool? isFavorite,
    String? errorMessage,
  }) {
    return RecipeDetailState(
      status: status ?? this.status,
      recipe: recipe ?? this.recipe,
      isFavorite: isFavorite ?? this.isFavorite,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recipe, isFavorite, errorMessage];
}
