import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class TutorialVideo extends StatefulWidget {
  const TutorialVideo({super.key});

  @override
  State<TutorialVideo> createState() => _TutorialVideoState();
}

class _TutorialVideoState extends State<TutorialVideo> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableJavaScript: true,
        strictRelatedVideos: true,
      ),
    );

    // ضع معرف الفيديو هنا
    // _controller.loadVideoById(videoId: "CabmgsR3xxw");
    _controller.cueVideoById(videoId: "CabmgsR3xxw");
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h, // أو أي ارتفاع تريده
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: YoutubePlayer(controller: _controller),
            );
          },
        ),
      ),
    );
  }
}
