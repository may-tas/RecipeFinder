import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../models/recipe_model.dart';

class RecipeOverviewTab extends StatefulWidget {
  final Recipe recipe;

  const RecipeOverviewTab({super.key, required this.recipe});

  @override
  State<RecipeOverviewTab> createState() => _RecipeOverviewTabState();
}

class _RecipeOverviewTabState extends State<RecipeOverviewTab> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final videoId = YoutubePlayer.convertUrlToId(widget.recipe.videoUrl ?? '');
    if (videoId != null) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_youtubeController != null) ...[
          Text('Watch How to Make', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: YoutubePlayer(
                controller: _youtubeController!,
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
          ),
          const SizedBox(height: 24),
        ],
        Text('About this Recipe', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Text(
          'Enjoy making this delicious ${widget.recipe.area} ${widget.recipe.category} dish. Follow the instructions tab for a step-by-step guide.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.lightGrey,
            height: 1.8,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _QuickInfoCard(
                icon: Icons.restaurant_rounded,
                label: 'Category',
                value: widget.recipe.category,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickInfoCard(
                icon: Icons.public_rounded,
                label: 'Cuisine',
                value: widget.recipe.area,
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
          Text(
            label,
            style: AppTextStyles.caption,
          ),
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
