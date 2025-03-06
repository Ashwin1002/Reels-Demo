import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/blocs/reels_controller.dart';
import 'package:video_player/video_player.dart';

const _iconSize = 52.0;

const _iconColor = AppColors.white70;

class VideoFullScreenPage extends StatelessWidget {
  final ReelsController controller;
  final VideoPlayerController videoPlayerController;

  const VideoFullScreenPage({
    super.key,
    required this.controller,
    required this.videoPlayerController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: context.height,
          width: context.width,
          color: AppColors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: VideoPlayer(videoPlayerController),
            ),
          ),
        ),
        Positioned(
          child: Center(
            child: AnimatedOpacity(
              opacity: controller.visible ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              child:
                  videoPlayerController.value.isPlaying
                      ? const Icon(
                        Icons.play_arrow,
                        color: _iconColor,
                        size: _iconSize,
                      )
                      : const Icon(
                        Icons.pause,
                        color: _iconColor,
                        size: _iconSize,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
