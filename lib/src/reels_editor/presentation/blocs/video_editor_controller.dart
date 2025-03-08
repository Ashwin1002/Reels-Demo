// ignore_for_file: unused_element

import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels_editor/domain/entities/song.dart';

class VideoInformation extends Equatable {
  final String savedPath;
  // final Metadata audioMetaData;
  final PlatformFile platformFile;

  final List<File> frames;

  const VideoInformation({
    required this.savedPath,
    // required this.audioMetaData,
    required this.platformFile,
    required this.frames,
  });

  @override
  List<Object?> get props => [
    savedPath,
    // audioMetaData,
    platformFile,
    frames,
  ];

  VideoInformation copyWith({
    String? savedPath,
    // Metadata? audioMetaData,
    PlatformFile? platformFile,
    List<File>? frames,
  }) {
    return VideoInformation(
      savedPath: savedPath ?? this.savedPath,
      // audioMetaData: audioMetaData ?? this.audioMetaData,
      platformFile: platformFile ?? this.platformFile,
      frames: frames ?? this.frames,
    );
  }

  factory VideoInformation.initial() => VideoInformation(
    savedPath: "",
    platformFile: PlatformFile(name: "", size: 0),
    frames: [],
  );

  @override
  String toString() =>
      'VideoInformation(savedPath: $savedPath, platformFile: $platformFile, frames: $frames)';
}

class VideoEditorController extends ChangeNotifier {
  VideoEditorController();
  VideoInformation? _videoInformation;
  VideoInformation? get videoInformation => _videoInformation;
  set videoInformation(VideoInformation? value) {
    _videoInformation = value;
    notifyListeners();
  }

  String? _videoPath;
  String? get videoPath => _videoPath;
  set videoPath(String? value) {
    _videoPath = value;
    notifyListeners();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  set isProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  String? _outputOriginalAudioPath;
  String? get outputOriginalAudioPath => _outputOriginalAudioPath;
  set outputAudioPath(String? value) {
    _outputOriginalAudioPath = value;
    notifyListeners();
  }

  Future<VideoInformation?> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      _videoPath = result.files.single.path;
      log('vid path => $_videoPath');

      _videoInformation = VideoInformation(
        savedPath: _videoPath ?? "",
        platformFile: result.files.single,
        frames: [],
      );

      // await _extractAudio();

      // await Future.wait([_extractMetadataAndThumbnail(), _extractAudio()]);
    } else {
      return null;
    }

    return _videoInformation;
  }

  // Future<void> _extractMetadataAndThumbnail() async {
  //   if (_videoPath == null) return;
  //   try {
  //     final metadata = await MetadataRetriever.fromFile(File(_videoPath!));
  //     _videoInformation = _videoInformation?.copyWith(audioMetaData: metadata);
  //   } catch (e) {
  //     log('Metadata error: $e');
  //   }
  // }

  Future<void> _extractAudio() async {
    if (_videoPath == null) return;

    _isProcessing = true;

    final dir = await getTemporaryDirectory();

    final outputPath =
        '${dir.path}/${_videoInformation?.platformFile.name}.${_videoInformation?.platformFile.extension}';

    await FFmpegKit.execute(
      '-i "$_videoPath" -vn -q:a 0 -map_metadata 0 "$outputPath"',
    ).then((session) async {
      final returnCode = await session.getReturnCode();
      if (returnCode!.isValueSuccess()) {
        _outputOriginalAudioPath = outputPath;
      }
    });
    _isProcessing = false;
  }

  Future<List<File>> _extractFrames(String videoPath) async {
    if (videoPath.isEmpty) return [];
    List<File> frames = [];
    final directory = await getApplicationDocumentsDirectory();
    String outputPath = '${directory.path}/frames';

    // Ensure the output directory exists
    Directory(outputPath).createSync(recursive: true);

    // FFmpeg command: extract frames exactly at each second, scale to 320 pixels wide,
    // and output low-quality JPEG images.
    String command =
        '-ss 0 -i "$videoPath" -vf "fps=1,scale=320:-1" -q:v 31 "$outputPath/frame_%04d.jpg"';

    await FFmpegKit.execute(command);

    // Collect extracted frame images
    frames.addAll(
      await Isolate.run(
        () async => Directory(outputPath)
            .listSync()
            .where((file) => file.path.endsWith('.jpg'))
            .map((e) => File(e.path)),
      ),
    );

    return frames;
  }

  /// Exports the video with the selected song.
  /// - If [isVideoMuted] is false, the original video sound is merged with the song.
  /// - If [isVideoMuted] is true, the original audio is replaced with the song.
  Future<String> exportVideoWithSong({
    required Song song,
    required bool isVideoMuted,
  }) async {
    String songPath = "";
    final tempDirectory = await getTemporaryDirectory();
    // Check if the URL appears to be local (this is a simple check).
    if (!(song.url.startsWith('file://') || song.url.startsWith('/'))) {
      // Download the song if it's remote.
      final file = await RemoteServiceImpl().download(
        dio: Dio(),
        url: song.url,
        savedPath: "${tempDirectory.path}/${song.name}.mp3",
      );
      songPath = file.path;
    } else {
      songPath = song.url;
    }

    log("saved cached song path => $songPath");
    final directory = await getDownloadsDirectory();
    final outputPath =
        '${directory?.path}/${_videoInformation?.platformFile.name}';

    String command = "";
    if (!isVideoMuted) {
      // Merge the video's original audio with the song using the amix filter.
      command =
          '-i "$videoPath" -i "$songPath" -filter_complex "[0:a][1:a]amix=inputs=2:duration=first:dropout_transition=2[a]" -map 0:v -map "[a]" -c:v copy "$outputPath"';
    } else {
      // Replace the original audio with the song.
      command =
          '-i "$videoPath" -i "$songPath" -map 0:v -map 1:a -c:v copy -shortest "$outputPath"';
    }

    // Execute the FFmpeg command.
    await FFmpegKit.execute(command);

    return outputPath;
  }
}
