import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/home_cubit.dart';
import '../../injection_container.dart';
import '../widgets/home/home_app_bar.dart';
import '../widgets/home/home_search_bar.dart';
import '../widgets/home/category_selector.dart';
import '../widgets/home/recipe_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => locator<HomeCubit>(),
      child: const HomeView(),
    );
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
