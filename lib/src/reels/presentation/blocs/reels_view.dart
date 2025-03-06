import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/blocs/progress_colors.dart';
import 'package:reels_demo/src/reels/presentation/blocs/progresss_bar.dart';
import 'package:reels_demo/src/reels/presentation/blocs/reels_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

const _iconSize = 52.0;
const _iconColor = AppColors.white;
typedef VideoPlayerBuilder =
    Widget Function(
      BuildContext context,
      int index,
      Widget child,
      VideoPlayerController videoPlayerController,
      PageController pageController,
      ReelsController controller,
      bool isSeeking,
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

  @override
  void initState() {
    super.initState();
    _isSeekingNotifier = ValueNotifier(false);
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
    _isSeekingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return PageView.builder(
            controller: _controller.pageController,
            itemCount: _controller.pageCount,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) => _buildTile(index),
          );
        },
      ),
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
      child: GestureDetector(
        onTap: () => _handleVideoTap(index),
        child: _buildVideoContent(index),
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
      isSeekingNotifier: _isSeekingNotifier,
    );

    return ValueListenableBuilder<bool>(
      valueListenable: _isSeekingNotifier,
      builder: (context, isSeeking, child) {
        return widget.builder?.call(
              context,
              index,
              videoWidget,
              _controller.videoPlayerControllerList[index],
              _controller.pageController,
              _controller,
              isSeeking,
            ) ??
            child!;
      },
      child: Container(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        color:
            _controller.videoPlayerControllerList[index].value.isPlaying
                ? AppColors.black38
                : AppColors.transparent,
        child: videoWidget,
      ),
    );
  }
}

class VideoFullScreenPage extends StatefulWidget {
  final ReelsController controller;
  final VideoPlayerController videoPlayerController;
  final ValueNotifier<bool> isSeekingNotifier;

  const VideoFullScreenPage({
    super.key,
    required this.controller,
    required this.videoPlayerController,
    required this.isSeekingNotifier,
  });

  static const _scaleFactor = 2;

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late final ValueNotifier<Duration> _currentValueNotifier;

  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _currentValueNotifier = ValueNotifier(
      widget.videoPlayerController.value.position,
    );

    _controller = widget.videoPlayerController;
    _controller.addListener(_onValueChangeListener);
  }

  @override
  void didUpdateWidget(covariant VideoFullScreenPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPlayerController.value.position !=
        oldWidget.videoPlayerController.value.position) {
      _currentValueNotifier.value = widget.videoPlayerController.value.position;
    }
  }

  void _onValueChangeListener() {
    _currentValueNotifier.value = _controller.value.position;
  }

  @override
  void deactivate() {
    _controller.removeListener(_onValueChangeListener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          child: Center(
            child: ListenableBuilder(
              listenable: widget.controller,
              builder:
                  (context, _) => Opacity(
                    opacity: 0.5,
                    child: AnimatedOpacity(
                      opacity: widget.controller.visible ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child:
                          _controller.value.isPlaying
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
        Positioned(
          bottom: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<Duration>(
                valueListenable: _currentValueNotifier,
                builder: (context, duration, _) {
                  return Center(
                    child: RichText(
                      text: TextSpan(
                        text: duration.formattedDuration,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: " / ",
                            style: TextStyle(
                              fontSize: 20.0,
                              color: AppColors.white70,
                            ),
                          ),
                          TextSpan(
                            text: _controller.value.duration.formattedDuration,
                            style: TextStyle(color: AppColors.white70),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: widget.isSeekingNotifier,
                builder: (context, isSeeking, _) {
                  final double barHeight =
                      (isSeeking ? VideoFullScreenPage._scaleFactor : 1) * 2;
                  final double handleHeight =
                      (isSeeking ? VideoFullScreenPage._scaleFactor : 1) * 2;
                  return SizedBox(
                    height: 50,
                    width: MediaQuery.sizeOf(context).width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: VideoProgressBar(
                        _controller,
                        barHeight: barHeight,
                        handleHeight: handleHeight,
                        drawShadow: false,
                        colors: ProgressColors(
                          playedColor: AppColors.progressBar,
                          bufferedColor: AppColors.white30,
                        ),
                        onDragStart:
                            () => widget.isSeekingNotifier.value = true,
                        onDragEnd: () async {
                          widget.isSeekingNotifier.value = false;
                          await _controller.play();
                        },
                        onDragUpdate:
                            (duration) =>
                                _currentValueNotifier.value = duration,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
