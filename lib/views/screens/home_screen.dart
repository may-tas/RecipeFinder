import 'package:flutter/material.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/category_selector.dart';
import '../widgets/home/recipe_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeView();
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          HomeAppBar(),
          HomeSearchBar(),
          CategorySelector(),
          Expanded(child: RecipeListView()),
        ],
      ),
    );
  }
}
