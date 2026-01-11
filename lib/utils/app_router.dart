import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/favorites_screen.dart';
import '../views/screens/recipe_detail_screen.dart';
import '../views/widgets/image_viewer_screen.dart';
import '../views/widgets/common/app_bottom_nav_bar.dart';
import '../models/recipe_model.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
              transitionDuration: const Duration(milliseconds: 200),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Slide direction based on whether we're entering or leaving
                final isForward =
                    secondaryAnimation.status == AnimationStatus.forward ||
                        secondaryAnimation.status == AnimationStatus.completed;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(isForward ? -0.3 : 0.3, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  )),
                  child: child,
                );
              },
            ),
          ),
          GoRoute(
            path: '/favorites',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FavoritesScreen(),
              transitionDuration: const Duration(milliseconds: 200),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Slide direction based on whether we're entering or leaving
                final isForward =
                    secondaryAnimation.status == AnimationStatus.forward ||
                        secondaryAnimation.status == AnimationStatus.completed;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(isForward ? 0.3 : -0.3, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastOutSlowIn,
                  )),
                  child: child,
                );
              },
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final recipe = state.extra as Recipe?;
          return CustomTransitionPage(
            key: state.pageKey,
            child: RecipeDetailScreen(recipeId: id, recipe: recipe),
            transitionDuration: const Duration(milliseconds: 350),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              // 2. Vertical Slide (from bottom)
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.15),
                  end: Offset.zero,
                ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/image-viewer',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          final imageUrl = extra['imageUrl'] as String;
          final tag = extra['tag'] as String;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ImageViewerScreen(imageUrl: imageUrl, tag: tag),
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 250),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
    ],
  );
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/favorites');
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.path;
    if (location == '/' && _currentIndex != 0) {
      setState(() => _currentIndex = 0);
    } else if (location == '/favorites' && _currentIndex != 1) {
      setState(() => _currentIndex = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
