import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/blocs/reels_controller.dart';
import 'package:reels_demo/src/reels/presentation/widgets/widgets.dart';
import 'package:video_player/video_player.dart';

const _iconSize = 52.0;
const _positionSize = 28.0;

const _iconColor = AppColors.white70;

class VideoFullScreenPage extends StatefulWidget {
  final ReelsController controller;
  final VideoPlayerController videoPlayerController;
  final void Function(bool isSeeking)? onSeeking;
  final bool isReelChanging;

  const VideoFullScreenPage({
    super.key,
    required this.controller,
    required this.videoPlayerController,
    required this.isReelChanging,
    this.onSeeking,
  });

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState();
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {
  late final ValueNotifier<Duration> _currentValueNotifier;
  late final ValueNotifier<bool> _isSeekingNotifier;
  late final ValueNotifier<bool> _isPlayingNotifier;

  late final VideoPlayerController _controller;

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

    _isSeekingNotifier.addListener(_onSeekingChangeListener);
  }

  void _onValueChangeListener() {
    _currentValueNotifier.value = _controller.value.position;
    _isPlayingNotifier.value = _controller.value.isPlaying;
    if (_controller.value.isCompleted) {
      _controller.play();
    }
  }

  void _onSeekingChangeListener() {
    widget.onSeeking?.call(_isSeekingNotifier.value);
  }

  @override
  void deactivate() {
    _controller.removeListener(_onValueChangeListener);
    _isSeekingNotifier.removeListener(_onSeekingChangeListener);

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
        if (!widget.isReelChanging)
          Positioned(
            bottom: 0,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSeekingNotifier,
              builder: (context, isSeeking, _) {
                final double barHeight = isSeeking ? 12 : 2;
                final double handleHeight = isSeeking ? 8 : 2;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40.0),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 100),
                        transitionBuilder: (child, animation) {
                          return SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          );
                        },
                        child:
                            isSeeking
                                ? _SeekingDurationView(
                                  key: ValueKey("seeking_duration_view"),
                                  currentValueNotifier: _currentValueNotifier,
                                  positionSize: _positionSize,
                                  controller: _controller,
                                )
                                : const SizedBox.shrink(
                                  key: ValueKey("seeking_duration_hidden_view"),
                                ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      height: !isSeeking ? 5 : 15,
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

class _SeekingDurationView extends StatelessWidget {
  const _SeekingDurationView({
    super.key,
    required ValueNotifier<Duration> currentValueNotifier,
    required double positionSize,
    required VideoPlayerController controller,
  }) : _currentValueNotifier = currentValueNotifier,
       _positionSize = positionSize,
       _controller = controller;

  final ValueNotifier<Duration> _currentValueNotifier;
  final double _positionSize;
  final VideoPlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Duration>(
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
                  style: TextStyle(fontSize: 20.0, color: AppColors.white70),
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
    );
  }
}
