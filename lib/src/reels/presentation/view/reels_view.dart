import 'package:flutter/material.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/widgets/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:whitecodel_reels/whitecodel_reels.dart';
import 'package:whitecodel_reels/whitecodel_reels_controller.dart';

typedef VideoPlayerBuilder =
    Widget Function(
      BuildContext context,
      int index,
      Widget child,
      VideoPlayerController videoPlayerController,
      PageController pageController,
      WhiteCodelReelsController controller,
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
  late final ValueNotifier<bool> _isSeekingNotifier;
  late final ValueNotifier<bool> _isReelChangingNotifier;

  @override
  void initState() {
    super.initState();

    _isSeekingNotifier = ValueNotifier(false);
    _isReelChangingNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isReelChangingNotifier.dispose();
    _isSeekingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WhiteCodelReels(
      context: context,
      videoList: widget.videoList,
      isCaching: widget.isCaching,
      loader: widget.loader,
      builder: (context, index, _, videoPlayerController, pageController) {
        return _buildTile(videoPlayerController);
      },
    );
  }

  Widget _buildTile(VideoPlayerController controller) {
    return Stack(
      children: [
        _buildVideoContent(controller),
        Positioned(
          left: 0.0,
          bottom: 0,
          right: 0.0,
          child: Opacity(
            opacity: 1,
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
        Positioned(
          right: 10,
          bottom: 100,
          child: Opacity(
            opacity: 1,
            child: ValueListenableBuilder<bool>(
              valueListenable: _isSeekingNotifier,
              builder: (context, isSeeking, _) {
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child:
                      isSeeking
                          ? const SizedBox.shrink(
                            key: ValueKey("action_hidden_view"),
                          )
                          : ReelsActions(key: ValueKey("action_shown_view")),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: PlayerSeeker(
            controller: controller,
            onSeeking: (isSeeking) {
              _isSeekingNotifier.value = isSeeking;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoContent(VideoPlayerController controller) {
    final videoWidget = VideoFullScreenPage(videoPlayerController: controller);

    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color:
          controller.value.isPlaying
              ? AppColors.black38
              : AppColors.transparent,
      child: videoWidget,
    );
  }
}
