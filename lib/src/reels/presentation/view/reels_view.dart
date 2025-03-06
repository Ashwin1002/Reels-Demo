import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/blocs/reels_controller.dart';
import 'package:reels_demo/src/reels/presentation/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

typedef VideoPlayerBuilder =
    Widget Function(
      BuildContext context,
      int index,
      Widget child,
      VideoPlayerController videoPlayerController,
      PageController pageController,
      ReelsController controller,
    );

class ReelsView extends StatefulWidget {
  final List<String>? videoList;
  final Widget? loader;
  final bool isCaching;
  final int startIndex;
  final VideoPlayerBuilder? builder;

  const ReelsView({
    super.key,
    this.videoList,
    this.loader,
    this.isCaching = false,
    this.builder,
    this.startIndex = 0,
  });

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> with TickerProviderStateMixin {
  late final ReelsController _controller;
  late final ValueNotifier<bool> _isSeekingNotifier;
  late final ValueNotifier<bool> _isReelChangingNotifier;

  @override
  void initState() {
    super.initState();
    _controller = ReelsController(
      vsync: this,
      reelsVideoList: widget.videoList ?? [],
      isCaching: widget.isCaching,
      startIndex: widget.startIndex,
    );

    _isSeekingNotifier = ValueNotifier(false);
    _isReelChangingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isReelChangingNotifier.dispose();
    _isSeekingNotifier.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return PageView.builder(
          controller: _controller.pageController,
          itemCount: _controller.pageCount,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) => _buildTile(index),
        );
      },
    );
  }

  Widget _buildTile(int index) {
    return VisibilityDetector(
      key: Key(index.toString()),
      onVisibilityChanged: (visibilityInfo) {
        _onVisibiltyChanged(visibilityInfo);
        if (visibilityInfo.visibleFraction < 0.5) {
          _controller.videoPlayerControllerList[index]
            ..seekTo(Duration.zero)
            ..pause();
          _controller.refreshView();
          _controller.animationController.stop();
        } else {
          // _controller.videoPlayerControllerList[index].play();
          Future.delayed(const Duration(milliseconds: 500), () {
            _controller.visible = false;
          });
          _controller.refreshView();
          _controller.animationController.repeat();
          _controller.initNearByVideos(index);
          if (!_controller.caching.contains(_controller.videoList[index])) {
            _controller.cacheVideo(index);
          }
          _controller.visible = false;
        }
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isReelChangingNotifier,
        builder: (context, isReelChanging, _) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () => _handleVideoTap(index),
                child: _buildVideoContent(index, isReelChanging),
              ),

              Positioned(
                right: 10,
                bottom: 100,
                child: Opacity(
                  opacity: isReelChanging ? .5 : 1,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isSeekingNotifier,
                    builder: (context, isSeeking, _) {
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child:
                            isSeeking
                                ? const SizedBox.shrink(
                                  key: ValueKey("action_hidden_view"),
                                )
                                : ReelsActions(
                                  key: ValueKey("action_shown_view"),
                                ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                left: 10.0,
                bottom: 20,
                right: 10.0,
                child: Opacity(
                  opacity: isReelChanging ? .5 : 1,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isSeekingNotifier,
                    builder: (context, isSeeking, _) {
                      return AnimatedSwitcher(
                        duration: Duration(milliseconds: 100),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              child: child,
                            ),
                          );
                        },
                        child:
                            isSeeking
                                ? const SizedBox.shrink(
                                  key: ValueKey("description_hidden_view"),
                                )
                                : ReelsDescriptionView(
                                  key: ValueKey("description_shown_view"),
                                  title: "",
                                  description: "",
                                ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onVisibiltyChanged(VisibilityInfo visibilityInfo) {
    if (visibilityInfo.visibleFraction > 0 &&
        visibilityInfo.visibleFraction < 1) {
      _isReelChangingNotifier.value = true;
    } else {
      _isReelChangingNotifier.value = false;
    }
  }

  void _handleVideoTap(int index) {
    final controller = _controller.videoPlayerControllerList[index];
    if (controller.value.isPlaying) {
      controller.pause();
      _controller.visible = true;
      _controller.refreshView();
      _controller.animationController.stop();
    } else {
      controller.play();
      _controller.visible = true;
      Future.delayed(const Duration(milliseconds: 500), () {
        _controller.visible = false;
      });
      _controller.refreshView();
      _controller.animationController.repeat();
    }
  }

  Widget _buildVideoContent(int index, bool isReelChanging) {
    final isLoading =
        _controller.loading ||
        !_controller.videoPlayerControllerList[index].value.isInitialized;
    if (isLoading) {
      return widget.loader ??
          const Center(child: CircularProgressIndicator(color: AppColors.red));
    }

    final videoWidget = VideoFullScreenPage(
      controller: _controller,
      videoPlayerController: _controller.videoPlayerControllerList[index],
      isReelChanging: isReelChanging,
      onSeeking: (isSeeking) {
        log("isSeeking: $isSeeking");
        _isSeekingNotifier.value = isSeeking;
      },
    );

    return widget.builder?.call(
          context,
          index,
          videoWidget,
          _controller.videoPlayerControllerList[index],
          _controller.pageController,
          _controller,
        ) ??
        Container(
          height: context.height,
          width: context.width,
          color:
              _controller.videoPlayerControllerList[index].value.isPlaying
                  ? AppColors.black38
                  : AppColors.transparent,
          child: videoWidget,
        );
  }
}
