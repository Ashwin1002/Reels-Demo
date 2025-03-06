import 'package:video_player/video_player.dart';

abstract class VideoControllerService {
  // Method to get a VideoPlayerController for a given video URL
  Future<VideoPlayerController> getControllerForVideo(
    String url,
    bool isCaching,
  );
}
