import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:reels_demo/src/reels/presentation/blocs/video_controller_service.dart';
import 'package:video_player/video_player.dart';

class ReelsController extends ChangeNotifier with WidgetsBindingObserver {
  final PageController pageController = PageController(
    viewportFraction: 0.99999,
  );
  final List<VideoPlayerController> videoPlayerControllerList = [];
  final CachedVideoControllerService videoControllerService =
      CachedVideoControllerService(DefaultCacheManager());
  final TickerProvider vsync;

  bool _loading = true;
  bool _visible = false;
  late AnimationController animationController;
  late Animation animation;

  int page = 1;
  final int limit = 10;
  final List<String> reelsVideoList;
  final bool isCaching;
  List<String> videoList = [];
  final int loadLimit = 2;
  bool init = false;
  Timer? timer;
  int? lastIndex;
  List<int> alreadyListened = [];
  List<String> caching = [];
  int pageCount = 0;
  final int startIndex;

  bool get loading => _loading;
  bool get visible => _visible;

  set visible(bool value) {
    _visible = value;
    notifyListeners();
  }

  ReelsController({
    required this.vsync,
    required this.reelsVideoList,
    required this.isCaching,
    this.startIndex = 0,
  }) {
    videoList.addAll(reelsVideoList);
    _initializeAnimation();
    WidgetsBinding.instance.addObserver(this);
    _initService(startIndex: startIndex);
    _startTimer();
  }

  void _initializeAnimation() {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 5),
    );
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeIn,
    );
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (lastIndex != null) {
        initNearByVideos(lastIndex!);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageController.dispose();
    animationController.dispose();
    timer?.cancel();
    for (final controller in videoPlayerControllerList) {
      controller.pause();
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      for (final controller in videoPlayerControllerList) {
        controller.pause();
      }
    }
  }

  Future<void> _initService({int startIndex = 0}) async {
    await addVideosController();
    final myIndex = startIndex;

    try {
      if (!videoPlayerControllerList[myIndex].value.isInitialized) {
        cacheVideo(myIndex);
        await videoPlayerControllerList[myIndex].initialize();
        _increasePage(myIndex + 1);
      }
    } catch (e) {
      log('Error initializing video at index $myIndex: $e');
    }

    animationController.repeat();
    videoPlayerControllerList[myIndex].play();
    refreshView();
    await initNearByVideos(myIndex);
    _loading = false;
    notifyListeners();

    Future.delayed(Duration.zero, () {
      pageController.jumpToPage(myIndex);
    });
  }

  void refreshView() {
    _loading = true;
    _loading = false;
    notifyListeners();
  }

  Future<void> addVideosController() async {
    for (final videoFile in videoList) {
      final controller = await videoControllerService.getControllerForVideo(
        videoFile,
        isCaching,
      );
      videoPlayerControllerList.add(controller);
    }
  }

  Future<void> initNearByVideos(int index) async {
    if (init) {
      lastIndex = index;
      return;
    }
    lastIndex = null;
    init = true;
    if (loading) return;
    await disposeNearByOldVideoControllers(index);
    await tryInit(index);

    try {
      final currentPage = index;
      final maxPage = currentPage + loadLimit;
      await _initializeNearbyVideos(currentPage, maxPage);
      await _initializePreviousVideos(index);
      refreshView();
    } catch (e) {
      _loading = false;
      notifyListeners();
    } finally {
      init = false;
      notifyListeners();
    }
  }

  Future<void> _initializeNearbyVideos(int currentPage, int maxPage) async {
    for (var i = currentPage; i < maxPage; i++) {
      if (videoList.asMap().containsKey(i)) {
        final controller = videoPlayerControllerList[i];
        if (!controller.value.isInitialized) {
          cacheVideo(i);
          await controller.initialize();
          _increasePage(i + 1);
          refreshView();
        }
      }
    }
  }

  Future<void> _initializePreviousVideos(int index) async {
    for (var i = index - 1; i > index - loadLimit; i--) {
      if (videoList.asMap().containsKey(i)) {
        final controller = videoPlayerControllerList[i];
        if (!controller.value.isInitialized) {
          if (!caching.contains(videoList[index])) {
            cacheVideo(index);
          }
          await controller.initialize();
          _increasePage(i + 1);
          refreshView();
        }
      }
    }
  }

  Future<void> tryInit(int index) async {
    final oldController = videoPlayerControllerList[index];
    if (oldController.value.isInitialized) {
      oldController.play();
      notifyListeners();
      return;
    }

    final newController = await videoControllerService.getControllerForVideo(
      videoList[index],
      isCaching,
    );
    videoPlayerControllerList[index] = newController;
    await oldController.dispose();
    refreshView();

    if (!caching.contains(videoList[index])) {
      cacheVideo(index);
    }

    await newController
        .initialize()
        .then((_) {
          newController.play();
          notifyListeners();
        })
        .catchError((e) {
          log('Error initializing controller: $e');
        });
  }

  Future<void> disposeNearByOldVideoControllers(int index) async {
    for (var i = index - loadLimit; i > 0; i--) {
      if (videoPlayerControllerList.asMap().containsKey(i)) {
        final oldController = videoPlayerControllerList[i];
        final newController = await videoControllerService
            .getControllerForVideo(videoList[i], isCaching);
        videoPlayerControllerList[i] = newController;
        alreadyListened.remove(i);
        await oldController.dispose();
        refreshView();
      }
    }

    for (var i = index + loadLimit; i < videoPlayerControllerList.length; i++) {
      if (videoPlayerControllerList.asMap().containsKey(i)) {
        final oldController = videoPlayerControllerList[i];
        final newController = await videoControllerService
            .getControllerForVideo(videoList[i], isCaching);
        videoPlayerControllerList[i] = newController;
        alreadyListened.remove(i);
        await oldController.dispose();
        refreshView();
      }
    }
  }

  void _increasePage(int v) {
    if (pageCount == videoList.length || pageCount >= v) return;
    pageCount = v;
    notifyListeners();
  }

  Future<void> cacheVideo(int index) async {
    if (!isCaching) return;
    final url = videoList[index];
    if (caching.contains(url)) return;
    caching.add(url);

    try {
      final cacheManager = DefaultCacheManager();
      final fileInfo = await cacheManager.getFileFromCache(url);
      if (fileInfo == null) {
        await cacheManager.downloadFile(url);
      }
    } catch (e) {
      caching.remove(url);
      log('Error caching video: $e');
    }
  }
}
