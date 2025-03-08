import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels_editor/presentation/blocs/video_editor/video_editor_cubit.dart';
import 'package:reels_demo/src/reels_editor/presentation/views/songs_list.dart';
import 'package:video_player/video_player.dart';

class ReelsEditorScreen extends StatefulWidget {
  const ReelsEditorScreen({super.key});

  @override
  State<ReelsEditorScreen> createState() => _ReelsEditorScreenState();
}

class _ReelsEditorScreenState extends State<ReelsEditorScreen> {
  late final VideoEditorCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = VideoEditorCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoEditorCubit>(
      create: (context) => _cubit,
      child: Builder(
        builder: (context) {
          final videoController = context
              .select<VideoEditorCubit, VideoPlayerController?>(
                (value) => value.playerController,
              );
          return Scaffold(
            backgroundColor: AppColors.darkBgColor,
            body: BlocBuilder<VideoEditorCubit, VideoEditorState>(
              buildWhen:
                  (previous, current) => previous.status != current.status,
              builder: (context, state) {
                return switch (state.status) {
                  LoadingStatus.loaded when videoController != null =>
                    VideoEditorSuccessView(videoController: videoController),
                  LoadingStatus.loading => Center(
                    child: Column(
                      spacing: 8.0,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        Text(
                          "Loading...",
                          style: context.theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ => VideoSelectorView(),
                };
              },
            ),
          );
        },
      ),
    );
  }
}

class VideoEditorSuccessView extends StatelessWidget {
  const VideoEditorSuccessView({super.key, required this.videoController});

  final VideoPlayerController videoController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoEditorCubit, VideoEditorState>(
      listenWhen: (p, c) => p.savingStatus != c.savingStatus,
      listener: (context, state) {
        switch (state.savingStatus) {
          case SavingStatus.saving:
            showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    insetPadding: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 8.0,
                      children: [
                        SizedBox.square(
                          dimension: 60,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Saving Video..."),
                        ),
                      ],
                    ),
                  ),
            );

          case SavingStatus.saved || SavingStatus.error:
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    state.savingStatus == SavingStatus.saved
                        ? "Saved Successfully!"
                        : "Failed to save video!",
                  ),
                ),
              );
            Navigator.pop(context);
          default:
        }
      },
      buildWhen:
          (previous, current) =>
              previous.videoPlayerValue != current.videoPlayerValue,
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  log("video pressed");
                  // if (state.videoPlayerValue?.isPlaying == true) {
                  //   context.read<VideoEditorCubit>().pauseVideo();
                  // } else {
                  //   context.read<VideoEditorCubit>().playVideo();
                  // }
                },
                child: Container(
                  height: context.height,
                  width: context.width,
                  color: AppColors.darkBgColor,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio:
                            state.videoPlayerValue?.aspectRatio ?? 9 / 16,
                        child: VideoPlayer(videoController),
                      ),
                      Positioned(
                        top: 60,
                        right: 10,
                        child: IconButton(
                          onPressed: () {
                            if (state.videoPlayerValue?.volume == 0) {
                              context.read<VideoEditorCubit>().unMuteAudio();
                            } else {
                              context.read<VideoEditorCubit>().muteAudio();
                            }
                          },
                          icon: Icon(
                            state.videoPlayerValue?.volume == 0
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 120,
                        right: 10,
                        child: IconButton(
                          onPressed: () {
                            // if (state.videoPlayerValue?.volume == 0) {
                            //   context.read<VideoEditorCubit>().unMuteAudio();
                            // } else {
                            //   context.read<VideoEditorCubit>().muteAudio();
                            // }
                            showModalBottomSheet(
                              context: context,
                              enableDrag: true,
                              isScrollControlled: true,
                              showDragHandle: true,
                              backgroundColor: AppColors.lightDarBgColor,
                              builder: (_) {
                                return SongsList(
                                  cubit: context.read<VideoEditorCubit>(),
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.music_note, color: AppColors.white),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        child: BlocBuilder<VideoEditorCubit, VideoEditorState>(
                          buildWhen: (p, c) => p.selectedSong != c.selectedSong,
                          builder: (context, state) {
                            if (state.selectedSong.url.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.black38,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                              ),
                              child: Row(
                                spacing: 4.0,
                                children: [
                                  Icon(
                                    Icons.music_note,
                                    color: AppColors.white,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      state.selectedSong.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.theme.textTheme.labelMedium
                                          ?.copyWith(color: AppColors.white),
                                    ),
                                  ),
                                  InkWell(
                                    onTap:
                                        () => context
                                            .read<VideoEditorCubit>()
                                            .onSongSelected(state.selectedSong),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 20.0,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              child: Row(
                spacing: 12.0,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () =>
                              context.read<VideoEditorCubit>().cancelPressed(),
                      child: Text("Cancel"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          () => showDialog(
                            context: context,

                            builder: (_) {
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20.0),
                                  ),
                                ),
                                child: SaveWidget(
                                  onSavePressed: (description, thumbnail) {
                                    context
                                        .read<VideoEditorCubit>()
                                        .exportVideo(
                                          description: description,
                                          thumbnail: thumbnail,
                                        );
                                  },
                                ),
                              );
                            },
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                      ),
                      child: Text(
                        "Save",
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class SaveWidget extends StatefulWidget {
  const SaveWidget({
    super.key,
    this.thumbnail,
    this.description,
    this.onSavePressed,
  });

  final String? thumbnail;
  final String? description;
  final void Function(String? description, String? thumbnail)? onSavePressed;

  @override
  State<SaveWidget> createState() => _SaveWidgetState();
}

class _SaveWidgetState extends State<SaveWidget> {
  late final TextEditingController _descriptionController;
  String? _selectedImage;

  @override
  void didUpdateWidget(covariant SaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.description != oldWidget.description) {
      _descriptionController.text = widget.description ?? "";
    }

    if (widget.thumbnail != oldWidget.thumbnail) {
      _selectedImage = widget.thumbnail;
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.thumbnail;
    _descriptionController = TextEditingController(
      text: widget.description ?? "",
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.0,
        children: [
          Text("Save Video", style: context.theme.textTheme.titleLarge),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              Text(
                "Thumbnail",
                style: context.theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w400,
                ),
              ),
              TapBouncer(
                onPressed: () async {
                  final file = await FilePickerUtils().pickImage();

                  setState(() {
                    _selectedImage = file?.path;
                  });
                },
                child: Container(
                  height: 100,
                  width: context.width,
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(
                      color: AppColors.grey600.withValues(alpha: .5),
                    ),
                  ),
                  child:
                      (_selectedImage ?? "").isNotEmpty
                          ? Image.asset(
                            _selectedImage ?? "",
                            fit: BoxFit.contain,
                          )
                          : Icon(
                            Icons.add_a_photo,
                            size: 60.0,
                            color: AppColors.grey600,
                          ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 2,
            decoration: InputDecoration(
              label: Text("Description"),
              labelStyle: context.theme.textTheme.bodyMedium,
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.grey600.withValues(alpha: .5),
                ),
              ),

              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.grey600.withValues(alpha: .5),
                ),
              ),
            ),
          ),
          SizedBox(
            width: context.width,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSavePressed?.call(
                  _descriptionController.text,
                  _selectedImage,
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
              child: Text(
                "Save",
                style: context.theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoSelectorView extends StatelessWidget {
  const VideoSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12.0,
        mainAxisSize: MainAxisSize.min,
        children: [
          TapBouncer(
            onPressed: () => context.read<VideoEditorCubit>().pickVideo(),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 12.0,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded, size: 60.0),
                    Text(
                      "Pick Video",
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            "Pick a video to get started",
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
