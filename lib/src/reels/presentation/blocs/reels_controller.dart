// import 'dart:async';
// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:reels_demo/src/reels/data/repository/cache_video_controller_service.dart';
// import 'package:video_player/video_player.dart';

// /// Controller class for managing reels.
// /// It initializes video controllers, handles caching, and manages nearby videos.
// class ReelsController extends ChangeNotifier with WidgetsBindingObserver {
//   /// Controller for swiping between pages.
//   final PageController pageController = PageController(
//     viewportFraction: 0.99999,
//   );

//   /// List of active video controllers.
//   final List<VideoPlayerController> videoPlayerControllerList = [];

//   /// Service to obtain (and cache) video controllers.
//   final CachedVideoControllerService videoControllerService =
//       CachedVideoControllerService(DefaultCacheManager());

//   /// Provider for ticker (used in animation controller).
//   final TickerProvider vsync;

//   bool _loading = true;
//   bool _visible = false;
//   late AnimationController animationController;
//   late Animation animation;

//   int page = 1;
//   final List<String> reelsVideoList;
//   final bool isCaching;
//   final List<String> videoList = [];
//   final int loadLimit = 2;
//   bool init = false;
//   Timer? timer;
//   int? lastIndex;
//   final List<int> alreadyListened = [];
//   final List<String> caching = [];
//   int pageCount = 0;
//   final int startIndex;

//   bool get loading => _loading;
//   bool get visible => _visible;

//   set visible(bool value) {
//     _visible = value;
//     notifyListeners();
//   }

//   ReelsController({
//     required this.vsync,
//     required this.reelsVideoList,
//     required this.isCaching,
//     this.startIndex = 0,
//   }) {
//     // Copy initial video URLs.
//     videoList.addAll(reelsVideoList);
//     _initializeAnimation();
//     WidgetsBinding.instance.addObserver(this);
//     _initService(startIndex: startIndex);
//     _startTimer();
//   }

//   /// Initialize the animation controller.
//   void _initializeAnimation() {
//     animationController = AnimationController(
//       vsync: vsync,
//       duration: const Duration(seconds: 5),
//     );
//     animation = CurvedAnimation(
//       parent: animationController,
//       curve: Curves.easeIn,
//     );
//   }

//   /// Starts a periodic timer to initialize nearby videos.
//   void _startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
//       if (lastIndex != null) {
//         initNearByVideos(lastIndex!);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     pageController.dispose();
//     animationController.dispose();
//     timer?.cancel();
//     for (final controller in videoPlayerControllerList) {
//       controller.pause();
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       for (final controller in videoPlayerControllerList) {
//         controller.pause();
//       }
//     }
//   }

//   /// Initialize the video service and load the initial video.
//   Future<void> _initService({int startIndex = 0}) async {
//     await addVideosController();
//     final myIndex = startIndex;
//     try {
//       final controller = videoPlayerControllerList[myIndex];
//       if (!controller.value.isInitialized) {
//         // Try caching the video (with a timeout).
//         await cacheVideo(myIndex).timeout(const Duration(seconds: 15));
//         await controller.initialize();
//         _increasePage(myIndex + 1);
//       }
//     } catch (e) {
//       log('Error initializing video at index $myIndex: $e');
//     }

//     animationController.repeat();
//     videoPlayerControllerList[myIndex].play();
//     // Initialize nearby videos.
//     await initNearByVideos(myIndex);
//     notifyListeners();

//     // Jump to the initial page after the build.
//     Future.delayed(Duration.zero, () {
//       pageController.jumpToPage(myIndex);
//     });
//   }

//   /// A helper to notify UI changes.
//   void refreshView() {
//     notifyListeners();
//   }

//   /// Creates video controllers for each video in [videoList].
//   Future<void> addVideosController() async {
//     for (final videoFile in videoList) {
//       try {
//         final controller = await videoControllerService.getControllerForVideo(
//           videoFile,
//           isCaching,
//         );
//         videoPlayerControllerList.add(controller);
//       } catch (e) {
//         log('Error adding video controller for $videoFile: $e');
//       }
//     }
//   }

//   /// Initialize nearby videos to improve swiping performance.
//   Future<void> initNearByVideos(int index) async {
//     log('index => $index');
//     if (init) {
//       lastIndex = index;
//       return;
//     }
//     lastIndex = null;
//     init = true;

//     // Avoid initializing if still loading.
//     if (_loading) {
//       init = false;
//       return;
//     }

//     await disposeNearByOldVideoControllers(index);
//     await tryInit(index);

//     try {
//       final currentPage = index;
//       final maxPage = currentPage + loadLimit;
//       await _initializeNearbyVideos(currentPage, maxPage);
//       await _initializePreviousVideos(index);
//       refreshView();
//     } catch (e) {
//       _loading = false;
//       refreshView();
//     } finally {
//       init = false;
//       refreshView();
//     }
//   }

//   /// Initialize videos ahead of the current page.
//   Future<void> _initializeNearbyVideos(int currentPage, int maxPage) async {
//     for (var i = currentPage; i < maxPage; i++) {
//       if (i < videoList.length) {
//         final controller = videoPlayerControllerList[i];
//         if (!controller.value.isInitialized) {
//           cacheVideo(i);
//           await controller.initialize();
//           _increasePage(i + 1);
//           refreshView();
//         }
//       }
//     }
//   }

//   /// Initialize videos before the current page.
//   Future<void> _initializePreviousVideos(int index) async {
//     for (var i = index - 1; i > index - loadLimit; i--) {
//       if (i >= 0 && i < videoList.length) {
//         final controller = videoPlayerControllerList[i];
//         if (!controller.value.isInitialized) {
//           if (!caching.contains(videoList[index])) {
//             cacheVideo(index);
//           }
//           await controller.initialize();
//           _increasePage(i + 1);
//           refreshView();
//         }
//       }
//     }
//   }

//   /// Try to initialize a single video at [index].
//   Future<void> tryInit(int index) async {
//     final oldController = videoPlayerControllerList[index];
//     if (oldController.value.isInitialized) {
//       await oldController.play();

//       notifyListeners();
//       return;
//     }

//     try {
//       final newController = await videoControllerService.getControllerForVideo(
//         videoList[index],
//         isCaching,
//       );
//       videoPlayerControllerList[index] = newController;
//       await oldController.dispose();
//       refreshView();

//       if (!caching.contains(videoList[index])) {
//         cacheVideo(index);
//       }

//       await newController.initialize();
//       await newController.play();
//       notifyListeners();
//     } catch (e) {
//       log('Error initializing controller at index $index: $e');
//     }
//   }

//   /// Dispose older video controllers around the current index.
//   Future<void> disposeNearByOldVideoControllers(int index) async {
//     // Dispose controllers before the current index.
//     for (var i = index - loadLimit; i < index; i++) {
//       if (i >= 0 && i < videoPlayerControllerList.length) {
//         final oldController = videoPlayerControllerList[i];
//         try {
//           final newController = await videoControllerService
//               .getControllerForVideo(videoList[i], isCaching);
//           videoPlayerControllerList[i] = newController;
//           alreadyListened.remove(i);
//           await oldController.dispose();
//           refreshView();
//         } catch (e) {
//           log('Error disposing controller at index $i: $e');
//         }
//       }
//     }

//     // Dispose controllers after the current index.
//     for (var i = index + loadLimit; i < videoPlayerControllerList.length; i++) {
//       try {
//         final oldController = videoPlayerControllerList[i];
//         final newController = await videoControllerService
//             .getControllerForVideo(videoList[i], isCaching);
//         videoPlayerControllerList[i] = newController;
//         alreadyListened.remove(i);
//         await oldController.dispose();
//         refreshView();
//       } catch (e) {
//         log('Error disposing controller at index $i: $e');
//       }
//     }
//   }

//   /// Increase the page count (used to control the number of pages in PageView).
//   void _increasePage(int newPageCount) {
//     log('Increasing page count to $newPageCount');
//     if (pageCount >= videoList.length || pageCount >= newPageCount) return;
//     pageCount = newPageCount;
//     notifyListeners();
//   }

//   /// Cache the video at [index] if caching is enabled.
//   Future<void> cacheVideo(int index) async {
//     if (!isCaching) return;
//     final url = videoList[index];
//     if (caching.contains(url)) return;
//     caching.add(url);

//     try {
//       final cacheManager = DefaultCacheManager();
//       final fileInfo = await cacheManager.getFileFromCache(url);
//       if (fileInfo == null) {
//         await cacheManager.downloadFile(url);
//       }
//     } catch (e) {
//       caching.remove(url);
//       log('Error caching video at index $index: $e');
//     }
//   }
// }
