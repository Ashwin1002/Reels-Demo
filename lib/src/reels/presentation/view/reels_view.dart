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

  @override
  void initState() {
    super.initState();
    _controller = ReelsController(
      vsync: this,
      reelsVideoList: widget.videoList ?? [],
      isCaching: widget.isCaching,
      startIndex: widget.startIndex,
    );
  }

  @override
  void dispose() {
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
        if (visibilityInfo.visibleFraction < 0.5) {
          _controller.videoPlayerControllerList[index]
            ..seekTo(Duration.zero)
            ..pause();
          _controller.refreshView();
          _controller.animationController.stop();
        } else {
          _controller.videoPlayerControllerList[index].play();
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
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _handleVideoTap(index),
            child: _buildVideoContent(index),
          ),
          Positioned(right: 10, bottom: 100, child: ReelsActions()),
          Positioned(
            left: 10.0,
            bottom: 20,
            right: 10.0,
            child: ReelsDescriptionView(title: "", description: ""),
          ),
        ],
      ),
    );
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

  Widget _buildVideoContent(int index) {
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
