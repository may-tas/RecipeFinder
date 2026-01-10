import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';

class RecipeOverviewTab extends StatelessWidget {
  final Recipe recipe;

  const RecipeOverviewTab({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final videoId = YoutubePlayer.convertUrlToId(recipe.videoUrl ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (videoId != null) ...[
          Text('Watch How to Make', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(autoPlay: false),
              ),
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.white,
              progressColors: const ProgressBarColors(
                playedColor: AppColors.white,
                handleColor: AppColors.white,
                backgroundColor: AppColors.midGrey,
                bufferedColor: AppColors.grey,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text('About this Recipe', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Text(
          'Enjoy making this delicious ${recipe.area} ${recipe.category} dish. Follow the instructions tab for a step-by-step guide.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.lightGrey,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 24),
        // Quick info cards
        Row(
          children: [
            Expanded(
              child: _QuickInfoCard(
                icon: Icons.restaurant_rounded,
                label: 'Category',
                value: recipe.category,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickInfoCard(
                icon: Icons.public_rounded,
                label: 'Cuisine',
                value: recipe.area,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.midGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey, size: 24),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
