import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../constants/app_colors.dart';
import '../../../models/recipe_model.dart';
import '../image_viewer_screen.dart';

class RecipeSliverAppBar extends StatelessWidget {
  final Recipe recipe;

  const RecipeSliverAppBar({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      backgroundColor: AppColors.deepGrey,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _GlassmorphicButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewerScreen(
                  imageUrl: recipe.thumbUrl,
                  tag: 'recipe_image_${recipe.id}',
                ),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: 'recipe_image_${recipe.id}',
                child: CachedNetworkImage(
                  imageUrl: recipe.thumbUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.midGrey),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.midGrey,
                    child: const Icon(
                      Icons.restaurant,
                      color: AppColors.grey,
                      size: 48,
                    ),
                  ),
                ),
              ),
              // Gradient overlay at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.imageOverlayGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassmorphicButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassmorphicButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.midGrey),
        ),
        child: Icon(icon, color: AppColors.white, size: 22),
      ),
    );
  }
}
