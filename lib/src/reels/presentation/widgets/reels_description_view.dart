import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';

class ReelsDescriptionView extends StatefulWidget {
  const ReelsDescriptionView({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  State<ReelsDescriptionView> createState() => _ReelsDescriptionViewState();
}

class _ReelsDescriptionViewState extends State<ReelsDescriptionView> {
  late final ValueNotifier<bool> _isExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _isExpandedNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isExpandedNotifier,
      builder: (context, isExpanded, child) {
        return Container(
          width: context.width,
          decoration: BoxDecoration(
            gradient:
                !isExpanded
                    ? null
                    : LinearGradient(
                      colors: [
                        AppColors.transparent,
                        AppColors.black38,
                        AppColors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 20.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    spacing: 4.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title.isEmpty ? "Video title" : widget.title,
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      AnimatedReadMoreText(
                        widget.description.isEmpty
                            ? "Video description please look into this long description. New viral tiktok video of 2025, #nepalimuser #travisscott #new #fyp #trending #foryou #nepalimusicideo"
                            : widget.description,
                        maxLines: 2,
                        maxHeightScale: .4,
                        textStyle: context.theme.textTheme.labelMedium
                            ?.copyWith(color: AppColors.white),
                        buttonTextStyle: context.theme.textTheme.labelMedium
                            ?.copyWith(color: AppColors.white70),
                        onViewChanged: (isExpanded) {
                          log("is Expanded => $isExpanded");
                          _isExpandedNotifier.value = isExpanded;
                        },
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
          ),
        );
      },
    );
  }
}
