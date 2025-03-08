part of 'video_editor_cubit.dart';

enum LoadingStatus { initial, loading, loaded, error }

enum AudioPlayingStatus { initial, loading, playing, completed }

enum SavingStatus { initial, saving, saved, error }

class VideoEditorState extends Equatable {
  const VideoEditorState({
    required this.videoInformation,
    required this.status,
    required this.videoPath,
    required this.outputOrgAudioPath,
    this.videoPlayerValue,
    required this.selectedSong,
    required this.songAudioPlayingStatus,
    required this.savingStatus,
  });
  factory VideoEditorState.initial() => VideoEditorState(
    videoInformation: VideoInformation.initial(),
    status: LoadingStatus.initial,
    videoPath: "",
    outputOrgAudioPath: "",
    selectedSong: Song.fakeData(),
    songAudioPlayingStatus: AudioPlayingStatus.initial,
    savingStatus: SavingStatus.initial,
  );

  final VideoInformation videoInformation;
  final LoadingStatus status;
  final String videoPath;
  final String outputOrgAudioPath;
  final VideoPlayerValue? videoPlayerValue;
  final Song selectedSong;
  final AudioPlayingStatus songAudioPlayingStatus;
  final SavingStatus savingStatus;

  @override
  List<Object?> get props => [
    videoInformation,
    status,
    videoPath,
    outputOrgAudioPath,
    videoPlayerValue,
    selectedSong,
    songAudioPlayingStatus,
    savingStatus,
  ];

  VideoEditorState copyWith({
    VideoInformation? videoInformation,
    LoadingStatus? status,
    String? videoPath,
    String? outputOrgAudioPath,
    VideoPlayerValue? videoPlayerValue,
    Song? selectedSong,
    AudioPlayingStatus? songAudioPlayingStatus,
    SavingStatus? savingStatus,
  }) {
    return VideoEditorState(
      videoInformation: videoInformation ?? this.videoInformation,
      status: status ?? this.status,
      videoPath: videoPath ?? this.videoPath,
      outputOrgAudioPath: outputOrgAudioPath ?? this.outputOrgAudioPath,
      videoPlayerValue: videoPlayerValue ?? this.videoPlayerValue,
      selectedSong: selectedSong ?? this.selectedSong,
      songAudioPlayingStatus:
          songAudioPlayingStatus ?? this.songAudioPlayingStatus,
      savingStatus: savingStatus ?? this.savingStatus,
    );
  }
}
