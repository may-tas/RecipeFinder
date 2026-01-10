import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool showBorder;

  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    this.onTap,
    this.size = 44,
    this.iconSize = 22,
    this.showBorder = true,
  });

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: widget.showBorder
                  ? Border.all(color: AppColors.midGrey)
                  : null,
            ),
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite ? AppColors.accentRed : AppColors.white,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
