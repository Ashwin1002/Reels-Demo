// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:reels_demo/core/core.dart';
// import 'package:reels_demo/src/reels/data/repository/cache_video_controller_service.dart';
// import 'package:video_player/video_player.dart';

// class ReelsController extends ChangeNotifier with WidgetsBindingObserver {
//   final List<String> urls;
//   final int maxCacheData;
//   final bool saveVideoToCache;

//   // PageView controller.
//   final PageController pageController = PageController(
//     viewportFraction: 0.99999,
//   );
//   // Notifier for scrolling state.
//   final ValueNotifier<bool> isScrollingNotifier = ValueNotifier<bool>(false);

//   // List holding the state for each video controller.
//   late List<AppState<VideoPlayerController>> videoStates;

//   // Video controller service and cache manager.
//   late final CachedVideoControllerService _service;
//   late final DefaultCacheManager _cacheManager;

//   // The currently active page index.
//   int currentIndex = 0;
//   // Flag indicating if the video was manually paused.
//   bool _manuallyPaused = false;

//   // Timer to periodically preload nearby videos.
//   Timer? timer;

//   ReelsController({
//     required this.urls,
//     this.maxCacheData = 5,
//     this.saveVideoToCache = false,
//   }) {
//     _cacheManager = DefaultCacheManager();
//     _service = CachedVideoControllerService(_cacheManager);
//     // Initialize all states as Initial.
//     videoStates = List<AppState<VideoPlayerController>>.filled(
//       urls.length,
//       const InitialState<VideoPlayerController>(),
//       growable: false,
//     );
//     WidgetsBinding.instance.addObserver(this);
//     pageController.addListener(_onPageChangeListener);

//     // Start a periodic timer to preload nearby videos.
//     timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       initNearByVideos(currentIndex);
//     });

//     // Initialize controllers and play the starting video.
//     initService(startIndex: 0);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     pageController.dispose();
//     isScrollingNotifier.dispose();
//     timer?.cancel();
//     // Dispose any loaded controllers.
//     for (int i = 0; i < videoStates.length; i++) {
//       if (videoStates[i].isLoaded) {
//         videoStates[i].when(
//           error: (e) {},
//           loading: () {},
//           loaded: (controller) {
//             controller.pause();
//             controller.dispose();
//           },
//         );
//       }
//     }
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Pause the current video when the app goes inactive.
//     videoStates[currentIndex].when(
//       error: (e) {},
//       loading: () {},
//       loaded: (controller) => controller.pause(),
//     );
//   }

//   /// Listens to PageView updates.
//   /// Pauses the current video while scrolling.
//   /// When scrolling stops (and if the video wasn’t manually paused), resumes playback.
//   void _onPageChangeListener() {
//     final double? page = pageController.page;
//     final int newIndex = page?.round() ?? 0;
//     final bool scrolling = ((page ?? 0) - newIndex).abs() > 0.01;
//     isScrollingNotifier.value = scrolling;

//     if (scrolling) {
//       videoStates[currentIndex].when(
//         error: (e) {},
//         loading: () {},
//         loaded: (controller) => controller.pause(),
//       );
//     } else {
//       if (!_manuallyPaused && newIndex == currentIndex) {
//         videoStates[currentIndex].when(
//           error: (e) {},
//           loading: () {},
//           loaded: (controller) => controller.play(),
//         );
//       }
//     }
//   }

//   /// Initializes video controllers for the first [maxCacheData] videos,
//   /// then starts playback of the video at [startIndex].
//   Future<void> initService({int startIndex = 0}) async {
//     currentIndex = startIndex;
//     final int preloadCount =
//         urls.length < maxCacheData ? urls.length : maxCacheData;
//     for (int i = 0; i < preloadCount; i++) {
//       await _initVideoController(i);
//     }
//     // Wait for the starting video to load.
//     await videoStates[startIndex].when(
//       error: (e) async {},
//       loading: () async {
//         await Future.doWhile(() async {
//           await Future.delayed(const Duration(milliseconds: 100));
//           return videoStates[startIndex].isLoading;
//         });
//       },
//       loaded: (controller) async {
//         controller.setLooping(true);
//         controller.play();
//       },
//     );
//     Future.delayed(Duration.zero, () {
//       pageController.jumpToPage(startIndex);
//     });
//   }

//   /// Initialize (or reinitialize) the video controller for a given index.
//   Future<void> _initVideoController(int index) async {
//     if (index < 0 || index >= urls.length) return;
//     // If already loaded, skip initialization.
//     if (videoStates[index].isLoaded) return;

//     videoStates[index] = const LoadingState<VideoPlayerController>();
//     notifyListeners();

//     try {
//       final VideoPlayerController controller = await _service
//           .getControllerForVideo(urls[index], saveVideoToCache);
//       await controller.initialize();
//       controller.addListener(() {
//         notifyListeners();
//       });
//       videoStates[index] = LoadedState(controller);
//       notifyListeners();
//     } catch (e) {
//       videoStates[index] = ErrorState(Exception(e.toString()));
//       notifyListeners();
//     }
//   }

//   /// Disposes the video controller at the given index (if loaded) and resets its state.
//   Future<void> _disposeVideoController(int index) async {
//     if (index < 0 || index >= videoStates.length) return;
//     if (videoStates[index].isLoaded) {
//       videoStates[index].when(
//         error: (e) {},
//         loading: () {},
//         loaded: (controller) {
//           controller.pause();
//           controller.dispose();
//         },
//       );
//       videoStates[index] = const InitialState<VideoPlayerController>();
//       notifyListeners();
//     }
//   }

//   /// Preloads nearby video controllers and disposes controllers too far from the current index.
//   Future<void> initNearByVideos(int index) async {
//     final int loadLimit = maxCacheData; // Adjust as needed.
//     // Preload videos in the active window.
//     for (int i = index; i < index + loadLimit && i < urls.length; i++) {
//       await _initVideoController(i);
//     }
//     for (int i = index - loadLimit; i < index; i++) {
//       if (i >= 0) await _initVideoController(i);
//     }
//     // Dispose controllers that fall outside the window.
//     for (int i = 0; i < urls.length; i++) {
//       if (i < index - loadLimit || i > index + loadLimit) {
//         await _disposeVideoController(i);
//       }
//     }
//   }

//   /// Called when the page has fully changed.
//   /// Disposes the previous video controller, resets the manual pause flag,
//   /// and loads and plays the new video.
//   Future<void> onPageChanged(int newIndex) async {
//     if (newIndex != currentIndex) {
//       await _disposeVideoController(currentIndex);
//     }
//     currentIndex = newIndex;
//     _manuallyPaused = false;
//     await _initVideoController(newIndex);
//     videoStates[newIndex].when(
//       error: (e) {},
//       loading: () {},
//       loaded: (controller) {
//         controller.setLooping(true);
//         controller.play();
//       },
//     );
//     notifyListeners();
//   }

//   /// Called when the user manually pauses the video.
//   Future<void> userPause() async {
//     videoStates[currentIndex].when(
//       error: (e) {},
//       loading: () {},
//       loaded: (controller) => controller.pause(),
//     );
//     notifyListeners();
//   }

//   /// Called when the user triggers play (if the video was manually paused).
//   Future<void> userPlay() async {
//     videoStates[currentIndex].when(
//       error: (e) {},
//       loading: () {},
//       loaded: (controller) => controller.play(),
//     );
//     notifyListeners();
//   }

//   /// Exposes the current video state.
//   AppState<VideoPlayerController> get currentVideoState =>
//       videoStates[currentIndex];

//   /// Returns true if the current video is loading (not initialized or buffering).
//   bool get isCurrentVideoLoading {
//     final state = currentVideoState;
//     return state.isLoading || !state.isLoaded;
//   }
// }
