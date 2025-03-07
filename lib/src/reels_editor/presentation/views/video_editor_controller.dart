import 'package:equatable/equatable.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path_provider/path_provider.dart';

class VideoInformation extends Equatable {
  final String savedPath;
  // final Metadata audioMetaData;
  final PlatformFile platformFile;

  const VideoInformation({
    required this.savedPath,
    // required this.audioMetaData,
    required this.platformFile,
  });

  @override
  List<Object?> get props => [
    savedPath,
    // audioMetaData,
    platformFile,
  ];

  VideoInformation copyWith({
    String? savedPath,
    // Metadata? audioMetaData,
    PlatformFile? platformFile,
  }) {
    return VideoInformation(
      savedPath: savedPath ?? this.savedPath,
      // audioMetaData: audioMetaData ?? this.audioMetaData,
      platformFile: platformFile ?? this.platformFile,
    );
  }
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

  Future<void> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      _videoPath = result.files.single.path;
      _videoInformation = _videoInformation?.copyWith(
        platformFile: result.files.single,
      );
      await _extractAudio();
      // await Future.wait([_extractMetadataAndThumbnail(), _extractAudio()]);
    }
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
}
