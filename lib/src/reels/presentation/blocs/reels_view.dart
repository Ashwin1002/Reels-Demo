import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/blocs/progress_colors.dart';
import 'package:reels_demo/src/reels/presentation/blocs/progresss_bar.dart';
import 'package:reels_demo/src/reels/presentation/blocs/reels_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

const _iconSize = 52.0;
const _iconColor = AppColors.white70;
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

class VideoFullScreenPage extends StatefulWidget {
  final ReelsController controller;
  final VideoPlayerController videoPlayerController;

  const VideoFullScreenPage({
    super.key,
    required this.controller,
    required this.videoPlayerController,
  });

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late final ValueNotifier<Duration> _currentValueNotifier;
  late final ValueNotifier<bool> _isSeekingNotifier;
  late final ValueNotifier<bool> _isPlayingNotifier;

  late final VideoPlayerController _controller;

  static const _scaleFactor = 2;
  static const _positionSize = 28.0;

  @override
  void initState() {
    super.initState();
    _isSeekingNotifier = ValueNotifier<bool>(false);
    _isPlayingNotifier = ValueNotifier<bool>(false);

    _currentValueNotifier = ValueNotifier<Duration>(
      widget.videoPlayerController.value.position,
    );

    _controller = widget.videoPlayerController;
    _controller.addListener(_onValueChangeListener);
  }

  void _onValueChangeListener() {
    _currentValueNotifier.value = _controller.value.position;
    _isPlayingNotifier.value = _controller.value.isPlaying;
    if (_controller.value.isCompleted) {
      _controller.play();
    }
  }

  @override
  void deactivate() {
    _controller.removeListener(_onValueChangeListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _isPlayingNotifier.dispose();
    _isSeekingNotifier.dispose();
    _currentValueNotifier.dispose();
    super.dispose();
  }

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
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          child: Center(
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
        Positioned(
          bottom: 0,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isSeekingNotifier,
            builder: (context, isSeeking, _) {
              final double barHeight = (isSeeking ? _scaleFactor : 1) * 2;
              final double handleHeight = (isSeeking ? _scaleFactor : 1) * 2;
              return Column(
                children: [
                  if (isSeeking)
                    ValueListenableBuilder<Duration>(
                      valueListenable: _currentValueNotifier,
                      builder: (context, duration, _) {
                        return Center(
                          child: RichText(
                            text: TextSpan(
                              text: duration.formattedDuration,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: _positionSize,
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
                                  text:
                                      _controller
                                          .value
                                          .duration
                                          .formattedDuration,
                                  style: TextStyle(color: AppColors.white70),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(
                    height: 5,
                    width: context.width,
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
                        onDragStart: () => _isSeekingNotifier.value = true,
                        onDragEnd: () async {
                          _isSeekingNotifier.value = false;
                          await _controller.play();
                        },
                        onDragUpdate:
                            (duration) =>
                                _currentValueNotifier.value = duration,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
