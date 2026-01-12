import 'package:flutter/material.dart';
import 'package:posha/utils/size_config.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_strings.dart';
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
          Text(AppStrings.watchHowToMake, style: AppTextStyles.h3),
          SizedBox(height: SizeConfig.getPercentSize(3)),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(3)),
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
          SizedBox(height: SizeConfig.getPercentSize(6)),
        ],
        Text(AppStrings.aboutThisRecipe, style: AppTextStyles.h3),
        SizedBox(height: SizeConfig.getPercentSize(3)),
        Text(
          'Enjoy making this delicious ${widget.recipe.area} ${widget.recipe.category} dish. Follow the instructions tab for a step-by-step guide.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.lightGrey,
            height: 1.8,
          ),
        ),
        SizedBox(height: SizeConfig.getPercentSize(6)),
        Row(
          children: [
            Expanded(
              child: _QuickInfoCard(
                icon: Icons.restaurant_rounded,
                label: AppStrings.labelCategory,
                value: widget.recipe.category,
              ),
            ),
            SizedBox(width: SizeConfig.getPercentSize(3)),
            Expanded(
              child: _QuickInfoCard(
                icon: Icons.public_rounded,
                label: AppStrings.labelCuisine,
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
      padding: EdgeInsets.all(SizeConfig.getPercentSize(4)),
      decoration: BoxDecoration(
        color: AppColors.midGrey,
        borderRadius: BorderRadius.circular(SizeConfig.getPercentSize(3)),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.grey, size: SizeConfig.getPercentSize(6)),
          SizedBox(height: SizeConfig.getPercentSize(2)),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
          SizedBox(height: SizeConfig.getPercentSize(1)),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: SizeConfig.getPercentSize(3.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
