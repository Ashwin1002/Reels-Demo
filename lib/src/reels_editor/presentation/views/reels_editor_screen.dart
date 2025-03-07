import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels_editor/presentation/views/video_editor_controller.dart';
import 'package:video_player/video_player.dart';

class ReelsEditorScreen extends StatefulWidget {
  const ReelsEditorScreen({super.key});

  @override
  State<ReelsEditorScreen> createState() => _ReelsEditorScreenState();
}

class _ReelsEditorScreenState extends State<ReelsEditorScreen> {
  String? _videoPath;
  VideoPlayerController? _videoController;
  double _videoDuration = 0.0;

  // Predefined audio files.
  // (Make sure these files exist on device or copy from assets to a temp folder.)
  final List<String> _audioFiles = [Songs.apt];
  int _selectedAudioIndex = 0;
  bool _isMuted = false;

  final VideoEditorController _videoEditorController = VideoEditorController();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioPlaying = false;

  @override
  void dispose() {
    _videoEditorController.dispose();
    _videoController?.dispose();
    _audioPlayer.dispose(); // Dispose audio player
    super.dispose();
  }

  /// Load and play the selected audio
  Future<void> _playSelectedAudio() async {
    if (_isMuted) return;

    await _audioPlayer.stop();
    await _audioPlayer.setSourceDeviceFile(_audioFiles[_selectedAudioIndex]);

    if (_videoController != null && _videoController!.value.isPlaying) {
      await _audioPlayer.seek(_videoController!.value.position);
      await _audioPlayer.resume();
    } else {
      await _audioPlayer.play(
        DeviceFileSource(_audioFiles[_selectedAudioIndex]),
      );
    }

    // Sync audio with video
    _videoController?.addListener(() {
      if (_videoController!.value.isPlaying && !_isAudioPlaying) {
        _audioPlayer.resume();
        _isAudioPlaying = true;
      } else if (!_videoController!.value.isPlaying && _isAudioPlaying) {
        _audioPlayer.pause();
        _isAudioPlaying = false;
      }
    });
  }

  /// Toggle mute and control audio
  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    if (_isMuted) {
      _audioPlayer.pause();
      _videoController?.setVolume(0);
    } else {
      _videoController?.setVolume(0); // Keep video muted
      _playSelectedAudio();
    }
  }

  /// Handle audio selection
  void _selectAudio(int index) {
    setState(() {
      _selectedAudioIndex = index;
    });
    _playSelectedAudio();
  }

  // Update _pickVideo to initialize audio
  Future<void> _pickVideo() async {
    await _videoEditorController.pickVideo().then((_) {
      _videoController = VideoPlayerController.file(File(_videoPath!))
        ..initialize().then((_) {
          setState(() {
            _videoDuration =
                _videoController!.value.duration.inSeconds.toDouble();
          });
          _videoController!.play();
          _videoController!.setVolume(0); // Mute original video audio
          _playSelectedAudio(); // Play selected audio
        });
    });
  }

  // Update _buildAudioPicker's onTap
  Widget _buildAudioPicker() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _audioFiles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _selectAudio(index), // Updated
            child: Container(
              // ... existing styling
            ),
          );
        },
      ),
    );
  }

  // Update _buildMuteButton to use _toggleMute
  Widget _buildMuteButton() {
    return ElevatedButton.icon(
      onPressed: _toggleMute, // Updated
      icon: Icon(_isMuted ? Icons.volume_off : Icons.volume_up),
      label: Text(_isMuted ? "Muted" : "Unmuted"),
    );
  }

  /// Processes the video by replacing or muting the audio.
  /// If not muted, the selected audio file will replace the current audio.
  /// The command uses the video duration (_videoDuration) to trim the audio if needed.
  Future<String?> _processVideo() async {
    if (_videoPath == null) return null;
    final directory = await getTemporaryDirectory();
    String outputPath = '${directory.path}/output_video.mp4';

    String command;
    if (_isMuted) {
      // Remove audio track if mute is enabled.
      command = '-i "$_videoPath" -c copy -an "$outputPath"';
    } else {
      String selectedAudioPath = _audioFiles[_selectedAudioIndex];
      // Replace audio with the selected file and trim to video length using -t.
      command =
          '-i "$_videoPath" -i "$selectedAudioPath" -c:v copy -map 0:v:0 -map 1:a:0 -t $_videoDuration -shortest "$outputPath"';
    }

    await FFmpegKit.execute(command);
    return outputPath;
  }

  /// Opens a dialog where the user can select a thumbnail image and add a description.
  Future<void> _showSaveDialog(String processedVideoPath) async {
    String? thumbnailPath;
    String description = '';
    final TextEditingController descController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Save Video Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image);
                    if (result != null) {
                      setState(() {
                        thumbnailPath = result.files.single.path;
                      });
                    }
                  },
                  child: Text(
                    thumbnailPath == null
                        ? "Pick Thumbnail"
                        : "Thumbnail Selected",
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: "Enter Description"),
                  onChanged: (value) {
                    description = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Here you can handle saving of the thumbnail, description, and processed video.
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Video saved with description and thumbnail.",
                    ),
                  ),
                );
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// Calls video processing and then opens the save dialog.
  void _saveVideo() async {
    String? outputVideoPath = await _processVideo();
    if (outputVideoPath != null) {
      await _showSaveDialog(outputVideoPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Audio Editor")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              _videoPath == null
                  ? Center(
                    child: ElevatedButton(
                      onPressed: _pickVideo,
                      child: Text("Pick Video"),
                    ),
                  )
                  : Column(
                    children: [
                      // Video preview
                      SizedBox(
                        height: 200,
                        child:
                            _videoController != null &&
                                    _videoController!.value.isInitialized
                                ? AspectRatio(
                                  aspectRatio:
                                      _videoController!.value.aspectRatio,
                                  child: VideoPlayer(_videoController!),
                                )
                                : Container(),
                      ),
                      SizedBox(height: 16),
                      // Audio picker similar to Facebook's story audio picker
                      _buildAudioPicker(),
                      SizedBox(height: 16),
                      // Mute toggle button
                      _buildMuteButton(),
                      SizedBox(height: 16),
                      // Save button
                      ElevatedButton(
                        onPressed: _saveVideo,
                        child: Text("Save Video"),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
