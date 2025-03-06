// Implementation of VideoControllerService that uses caching
import 'dart:developer';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:reels_demo/src/reels/data/repository/video_controller_service.dart';
import 'package:video_player/video_player.dart';

class CachedVideoControllerService extends VideoControllerService {
  final BaseCacheManager _cacheManager;

  // Constructor requiring a cache manager instance
  CachedVideoControllerService(this._cacheManager);

  @override
  Future<VideoPlayerController> getControllerForVideo(
    String url,
    bool isCaching,
  ) async {
    log('checking videos in cache');
    if (isCaching) {
      FileInfo? fileInfo;
      try {
        // Attempt to retrieve video file from cache
        fileInfo = await _cacheManager.getFileFromCache(url);
      } catch (e) {
        // Log error if encountered while getting video from cache
        log('Error getting video from cache: $e');
      }

      // Check if video file was found in cache
      if (fileInfo != null) {
        // Log that video was found in cache
        // log('Video found in cache');
        // Return VideoPlayerController for the cached file
        return VideoPlayerController.file(fileInfo.file);
      }

      try {
        // If video is not found in cache, attempt to download it
        await _cacheManager.downloadFile(url).timeout(Duration(seconds: 15));
      } catch (e) {
        // Log error if encountered while downloading video
        log('Error downloading video: $e');
      }
    }

    // Return VideoPlayerController for the video from the network
    return VideoPlayerController.networkUrl(Uri.parse(url));
  }
}
