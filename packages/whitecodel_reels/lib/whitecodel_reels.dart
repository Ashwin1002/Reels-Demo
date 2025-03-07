library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'whitecodel_reels_controller.dart';

const _iconSize = 52.0;

const _iconColor = Colors.white70;

class WhiteCodelReels extends GetView<WhiteCodelReelsController> {
  final BuildContext context;
  final List<String>? videoList;
  final Widget? loader;
  final bool isCaching;
  final int startIndex;
  final Widget Function(
    BuildContext context,
    int index,
    Widget child,
    VideoPlayerController videoPlayerController,
    PageController pageController,
  )? builder;

  const WhiteCodelReels({
    super.key,
    required this.context,
    this.videoList,
    this.loader,
    this.isCaching = false,
    this.builder,
    this.startIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    Get.delete<WhiteCodelReelsController>();
    Get.lazyPut<WhiteCodelReelsController>(
      () => WhiteCodelReelsController(
        reelsVideoList: videoList ?? [],
        isCaching: isCaching,
        startIndex: startIndex,
      ),
    );
    return Obx(
      () {
        if (controller.loading.value) {
          return loader ??
              const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
        }
        return PageView.builder(
          controller: controller.pageController,
          itemCount: controller.pageCount.value,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return buildTile(index);
          },
        );
      },
    );
  }

  Widget buildTile(index) {
    return VisibilityDetector(
      key: Key(index.toString()),
      onVisibilityChanged: (visibilityInfo) {
        if (controller.videoPlayerControllerList.isEmpty) return;
        if (visibilityInfo.visibleFraction < 0.5) {
          controller.videoPlayerControllerList[index].seekTo(Duration.zero);
          controller.videoPlayerControllerList[index].pause();
          // controller.visible.value = true;
          controller.refreshView();
          controller.animationController.stop();
        } else {
          controller.listenEvents(index);
          controller.videoPlayerControllerList[index].play();
          // controller.visible.value = true;
          Future.delayed(const Duration(milliseconds: 500), () {
            // controller.visible.value = false;
          });
          controller.refreshView();
          controller.animationController.repeat();
          controller.initNearByVideos(index);
          if (!controller.caching.contains(controller.videoList[index])) {
            controller.cacheVideo(index);
          }
          controller.visible.value = false;
        }
      },
      child: GestureDetector(
        onTap: () {
          if (controller.videoPlayerControllerList[index].value.isPlaying) {
            controller.videoPlayerControllerList[index].pause();
            controller.visible.value = true;
            controller.refreshView();
            controller.animationController.stop();
          } else {
            controller.videoPlayerControllerList[index].play();
            controller.visible.value = true;
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.visible.value = false;
            });

            controller.refreshView();
            controller.animationController.repeat();
          }
        },
        child: Obx(() {
          if (controller.loading.value ||
              !controller
                  .videoPlayerControllerList[index].value.isInitialized) {
            return loader ??
                const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
          }

          return builder == null
              ? VideoFullScreenPage(
                  videoPlayerController:
                      controller.videoPlayerControllerList[index],
                )
              : builder!(
                  context,
                  index,
                  VideoFullScreenPage(
                    videoPlayerController:
                        controller.videoPlayerControllerList[index],
                  ),
                  controller.videoPlayerControllerList[index],
                  controller.pageController,
                );
        }),
      ),
    );
  }
}

class VideoFullScreenPage extends StatelessWidget {
  final VideoPlayerController videoPlayerController;

  const VideoFullScreenPage({super.key, required this.videoPlayerController});

  @override
  Widget build(BuildContext context) {
    WhiteCodelReelsController controller =
        Get.find<WhiteCodelReelsController>();
    return Stack(
      children: [
        Container(
          height: context.height,
          width: context.width,
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: VideoPlayer(videoPlayerController),
            ),
          ),
        ),
        Positioned(
          child: Center(
            child: Obx(
              () => AnimatedOpacity(
                opacity: controller.visible.value ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black26,
                  ),
                  child: videoPlayerController.value.isPlaying
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
          ),
        ),
      ],
    );
  }
}
