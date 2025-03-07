import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/widgets/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReelsLoadingView extends StatelessWidget {
  const ReelsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SizedBox(
        height: context.height,
        width: context.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Skeleton.keep(
              child: SizedBox.square(
                dimension: 52.0,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: [AppColors.red, AppColors.white],
                ),
              ),
            ),
            Positioned(
              left: 0.0,
              bottom: 0,
              right: 0.0,
              child: ReelsDescriptionView(title: "", description: ""),
            ),
            Positioned(
              right: 10,
              bottom: 100,
              child: ReelsActions(key: ValueKey("action_shown_view")),
            ),
          ],
        ),
      ),
    );
  }
}
