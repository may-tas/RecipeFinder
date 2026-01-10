import 'package:equatable/equatable.dart';
import '../models/recipe_model.dart';

enum FavoritesStatus { initial, loading, success, failure }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<Recipe> favorites;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Recipe>? favorites,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
    );
  }

  @override
  List<Object> get props => [status, favorites];
}
