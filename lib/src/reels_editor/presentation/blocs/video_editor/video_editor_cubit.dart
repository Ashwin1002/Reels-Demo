import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_demo/src/reels_editor/domain/entities/song.dart';
import 'package:reels_demo/src/reels_editor/presentation/blocs/video_editor_controller.dart';
import 'package:video_player/video_player.dart';

part 'video_editor_state.dart';

class VideoEditorCubit extends Cubit<VideoEditorState> {
  VideoEditorCubit()
    : _audioPlayer = AudioPlayer(),
      _videoEditorController = VideoEditorController(),
      super(VideoEditorState.initial()) {
    subscribeToPlayerState();
  }

  final VideoEditorController _videoEditorController;
  final AudioPlayer _audioPlayer;
  VideoPlayerController? _playerController;

  VideoPlayerController? get playerController => _playerController;

  // Used to detect video looping by comparing positions.
  Duration _lastVideoPosition = Duration.zero;

  StreamSubscription<PlayerState>? _songBufferingSubscription;

  @override
  Future<void> close() {
    _songBufferingSubscription?.cancel();
    _audioPlayer.dispose();
    _videoEditorController.dispose();
    _playerController?.removeListener(_videoLoopListener);
    _playerController?.dispose();
    return super.close();
  }

  FutureOr<void> pickVideo() async {
    emit(state.copyWith(status: LoadingStatus.loading));
    final videoInfo = await _videoEditorController.pickVideo();
    emit(state.copyWith(videoInformation: videoInfo));

    if (videoInfo == null) return;

    emit(state.copyWith(videoPath: videoInfo.savedPath));

    try {
      _playerController = VideoPlayerController.file(
        File(videoInfo.savedPath),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      await _playerController?.initialize();

      // Add listener to detect video looping.
      _playerController?.addListener(_videoLoopListener);

      emit(
        state.copyWith(
          status: LoadingStatus.loaded,
          videoPath: videoInfo.savedPath,
          videoPlayerValue: _playerController?.value,
        ),
      );
      await playVideo();
    } catch (e) {
      log('Error initializing video: $e');
      emit(state.copyWith(status: LoadingStatus.error));
    }

    log("loading state => ${state.status}");
  }

  void _videoLoopListener() {
    if (_playerController == null || !_playerController!.value.isPlaying) {
      return;
    }

    final currentPos = _playerController!.value.position;

    // If the current position is less than the last recorded position,
    // the video has looped.
    if (currentPos < _lastVideoPosition) {
      log("Video loop detected.");
      if (state.selectedSong.url.isNotEmpty) {
        _restartPlayback();
      }
    }
    _lastVideoPosition = currentPos;
  }

  Future<void> _restartPlayback() async {
    // Stop both audio and video.
    await _audioPlayer.stop();
    await _playerController?.pause();

    // Restart audio using the selected song URL.
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.play(
      UrlSource(state.selectedSong.url),
      mode: PlayerMode.lowLatency,
      volume: 0.5,
    );
    // Wait until the audio buffering is complete.
    await _audioPlayer.onPlayerStateChanged.firstWhere(
      (event) => event == PlayerState.playing,
    );

    // Restart the video from the beginning.
    await _playerController?.seekTo(Duration.zero);
    await playVideo();
  }

  FutureOr<void> muteAudio() async {
    await _playerController?.setVolume(0);
    emit(state.copyWith(videoPlayerValue: _playerController?.value));
  }

  FutureOr<void> unMuteAudio() async {
    await _playerController?.setVolume(1);
    emit(state.copyWith(videoPlayerValue: _playerController?.value));
  }

  FutureOr<void> playVideo() async {
    await _playerController?.play();
    await _playerController?.setLooping(true);
    emit(state.copyWith(videoPlayerValue: _playerController?.value));
  }

  FutureOr<void> pauseVideo() async {
    await _playerController?.pause();
    emit(state.copyWith(videoPlayerValue: _playerController?.value));
  }

  FutureOr<void> cancelPressed() async {
    if (_playerController?.value.isInitialized == true) {
      _playerController?.dispose();
    }
    emit(
      state.copyWith(
        outputOrgAudioPath: null,
        status: LoadingStatus.initial,
        videoInformation: null,
        videoPath: null,
        videoPlayerValue: null,
      ),
    );
  }

  FutureOr<void> onSongSelected(Song song) async {
    // If the same song is tapped again, deselect and stop.
    if (song == state.selectedSong) {
      emit(state.copyWith(selectedSong: Song.fakeData()));
      await _audioPlayer.stop();
      return;
    }

    // Stop any currently playing audio.
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.stop();
    }

    // Update the selected song.
    emit(state.copyWith(selectedSong: song));

    // Set release mode to stop so the audio plays only once per video loop.
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Start playing the selected song.
    await _audioPlayer.play(
      UrlSource(song.url),
      mode: PlayerMode.lowLatency,
      volume: 0.5,
    );

    // Wait until the audio buffering is complete.
    await _audioPlayer.onPlayerStateChanged.firstWhere(
      (event) => event == PlayerState.playing,
    );

    // Then start the video.
    await playVideo();
  }

  FutureOr<void> subscribeToPlayerState() async {
    _audioPlayer.eventStream.listen((AudioEvent event) {});
    _songBufferingSubscription = _audioPlayer.onPlayerStateChanged.listen((
      status,
    ) {
      log("Audio player status => $status");
      emit(
        state.copyWith(
          songAudioPlayingStatus:
              status == PlayerState.playing
                  ? AudioPlayingStatus.playing
                  : AudioPlayingStatus.initial,
        ),
      );
    });
  }

  FutureOr<void> exportVideo() async {
    final isVideoMuted = state.videoPlayerValue?.volume == 0;

    emit(state.copyWith(savingStatus: SavingStatus.saving));

    try {
      final outputPath = await _videoEditorController.exportVideoWithSong(
        song: state.selectedSong,
        isVideoMuted: isVideoMuted,
      );

      log("saved video path => $outputPath");
      emit(
        state.copyWith(savingStatus: SavingStatus.saved, videoPath: outputPath),
      );
    } catch (e) {
      // Log error and update state accordingly.
      log('Error exporting video: $e');
      emit(state.copyWith(savingStatus: SavingStatus.error));
    }
  }
}
