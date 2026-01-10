import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String thumbUrl;
  final String description;

  const Category({
    required this.id,
    required this.name,
    required this.thumbUrl,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbUrl: json['strCategoryThumb'] ?? '',
      description: json['strCategoryDescription'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, thumbUrl, description];
}
