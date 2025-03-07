import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:reels_demo/core/core.dart';
import 'package:reels_demo/src/reels/presentation/widgets/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Reels Demo', home: const MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final videos = [
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: ReelsView(
        loader: Container(
          height: context.height,
          width: context.width,
          color: AppColors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.square(
                dimension: 52.0,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballBeat,
                  colors: [AppColors.red, AppColors.white],
                ),
              ),
              Positioned(
                left: 0.0,
                bottom: 0,
                right: 0.0,
                child: Skeletonizer(
                  enabled: true,
                  child: ReelsDescriptionView(title: "", description: ""),
                ),
              ),
              Positioned(
                right: 10,
                bottom: 100,
                child: Skeletonizer(
                  enabled: true,
                  child: ReelsActions(key: ValueKey("action_shown_view")),
                ),
              ),
            ],
          ),
        ),
        videoList: videos,
        isCaching: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.real_estate_agent),
            label: "Videos",
          ),
        ],
      ),
    );
  }
}
