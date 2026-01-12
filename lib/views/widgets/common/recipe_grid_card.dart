import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:posha/utils/size_config.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';
import 'animated_favorite_button.dart';

class RecipeGridCard extends StatefulWidget {
  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const RecipeGridCard({
    super.key,
    required this.recipe,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<RecipeGridCard> createState() => _RecipeGridCardState();
}

class _RecipeGridCardState extends State<RecipeGridCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () =>
          context.push('/details/${widget.recipe.id}', extra: widget.recipe),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _isPressed ? 0.0 : -5.0 * (_isPressed ? 0 : 1)),
        decoration: BoxDecoration(
          color: AppColors.darkGrey,
          borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(3)),
          border: Border.all(color: AppColors.midGrey),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: _isPressed ? 0.3 : 0.5),
              blurRadius: _isPressed ? 20 : 30,
              offset: Offset(0, _isPressed ? 10 : 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(SizeConfig.getPercentSize(3)),
                    ),
                    child: Hero(
                      tag: 'recipe_image_${widget.recipe.id}',
                      child: CachedNetworkImage(
                        imageUrl: widget.recipe.thumbUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.midGrey),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.midGrey,
                          child: const Icon(
                            Icons.restaurant,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: SizeConfig.getPercentSize(15),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.imageOverlayGradient,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(SizeConfig.getPercentSize(3)),
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: SizeConfig.getPercentSize(2),
                    right: SizeConfig.getPercentSize(2),
                    child: AnimatedFavoriteButton(
                      isFavorite: widget.isFavorite,
                      onTap: widget.onFavoriteToggle,
                      size: SizeConfig.getPercentSize(8),
                      iconSize: SizeConfig.getPercentSize(4.5),
                      showBorder: false,
                    ),
                  ),
                ],
              ),
            ),
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.getPercentSize(2.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: AppTextStyles.cardTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: SizeConfig.getPercentSize(1)),
                    Text(
                      '${widget.recipe.category} • ${widget.recipe.area}',
                      style: AppTextStyles.cardMeta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
