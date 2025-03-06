import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';

class ReelsDescriptionView extends StatelessWidget {
  const ReelsDescriptionView({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              spacing: 4.0,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? "Video title" : title,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                  ),
                ),
                AnimatedReadMoreText(
                  description.isEmpty
                      ? "Video description please look into this long description. New viral tiktok video of 2025, #nepalimuser #travisscott #new #fyp #trending #foryou #nepalimusic"
                      : description,
                  maxLines: 2,
                  textStyle: context.theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.white,
                  ),
                  buttonTextStyle: context.theme.textTheme.labelMedium
                      ?.copyWith(color: AppColors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Container(
              height: 40.0,
              width: 40.0,
              decoration: BoxDecoration(
                color: AppColors.white70,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(AssetList.music),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
