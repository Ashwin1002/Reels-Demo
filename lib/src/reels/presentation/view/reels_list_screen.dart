import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/blocs/reels/reels_cubit.dart';
import 'package:reels_demo/src/reels/presentation/view/reels_view.dart';
import 'package:reels_demo/src/reels/presentation/widgets/reels_loading_view.dart';

class ReelsListScreen extends StatelessWidget {
  const ReelsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelsCubit>(
      create: (context) => ReelsCubit()..fetchReels(),
      child: VideoReelsSrcView(),
    );
  }
}

class VideoReelsSrcView extends StatelessWidget {
  const VideoReelsSrcView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelsCubit, ReelsState>(
      buildWhen: (previous, current) => previous.reels != current.reels,
      builder: (context, state) {
        log("state => ${state.reels}");
        return state.reels.when(
          error:
              (e) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    "Error occurred while fetching list: $e",
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
          loading: () => ReelsLoadingView(),
          loaded: (data) {
            log('remote reels length => ${data.map((e) => e.videoUrl)}');
            return SizedBox(
              height: context.height,
              width: context.width,
              child: ReelsView(
                loader: ReelsLoadingView(),
                videoList: data.map((e) => e.videoUrl).toList(),
                isCaching: false,
                reels: data,
              ),
            );
          },
        );
      },
    );
  }
}
