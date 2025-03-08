import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels_editor/domain/entities/song.dart';
import 'package:reels_demo/src/reels_editor/presentation/blocs/songs/songs_cubit.dart';
import 'package:reels_demo/src/reels_editor/presentation/blocs/video_editor/video_editor_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SongsList extends StatelessWidget {
  const SongsList({super.key, required VideoEditorCubit cubit})
    : _cubit = cubit;

  final VideoEditorCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SongsCubit>(
          create: (context) => SongsCubit()..fetchSongs(),
        ),
        BlocProvider<VideoEditorCubit>.value(value: _cubit),
      ],
      child: Builder(
        builder: (context) {
          return BlocBuilder<SongsCubit, AppState<List<Song>>>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, state) {
              return state.when(
                error: (e) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        "Error occurred while fetching list: ",
                        textAlign: TextAlign.center,
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  );
                },
                loading: () {
                  return Skeletonizer(
                    enabled: true,
                    child: SongsListView(
                      songs: List.generate(8, (index) => Song.fakeData()),
                    ),
                  );
                },
                loaded: (data) => SongsListView(songs: data),
              );
            },
          );
        },
      ),
    );
  }
}

class SongsListView extends StatelessWidget {
  const SongsListView({super.key, required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height * .6,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: ListView(
        children: [
          Text(
            "Select Songs",
            style: context.theme.textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 20.0),
          ...List.generate(songs.length, (index) {
            final song = songs[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: BlocBuilder<VideoEditorCubit, VideoEditorState>(
                buildWhen: (p, c) {
                  return p.selectedSong != c.selectedSong ||
                      p.songAudioPlayingStatus != c.songAudioPlayingStatus;
                },
                builder: (context, state) {
                  return SongTile(
                    song: song,
                    isActive:
                        state.selectedSong == song &&
                        state.songAudioPlayingStatus ==
                            AudioPlayingStatus.playing,
                    isLoading:
                        state.songAudioPlayingStatus ==
                        AudioPlayingStatus.loading,
                    initialValue: state.selectedSong,
                    onChanged:
                        (song) => context
                            .read<VideoEditorCubit>()
                            .onSongSelected(song),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SongTile extends StatefulWidget {
  const SongTile({
    super.key,
    required this.song,
    this.initialValue,
    this.onChanged,
    this.isLoading = false,
    this.isActive = false,
  });

  final Song song;
  final Song? initialValue;
  final bool isActive;
  final bool isLoading;
  final void Function(Song song)? onChanged;

  @override
  State<SongTile> createState() => _SongTileState();
}

class _SongTileState extends State<SongTile> {
  Song? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant SongTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      selected = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapBouncer(
      onPressed: () => widget.onChanged?.call(widget.song),
      child: Container(
        decoration: BoxDecoration(
          color: !widget.isActive ? null : AppColors.white30,
          border: Border.all(color: AppColors.white30),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Row(
          spacing: 4.0,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: Image.asset(AssetList.music, height: 50, width: 50),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.0,
                  children: [
                    Text(
                      widget.song.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      spacing: 12.0,
                      children: [
                        Text(
                          widget.song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            widget.song.duration.formattedDuration,
                            style: context.theme.textTheme.labelMedium
                                ?.copyWith(color: AppColors.white70),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (widget.isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: CircularProgressIndicator(strokeCap: StrokeCap.round),
              ),
            if (widget.isActive)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: LottieBuilder.asset(
                  AssetList.nowPlaying,
                  width: 35.0,
                  height: 35.0,
                  repeat: true,
                  animate: true,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
