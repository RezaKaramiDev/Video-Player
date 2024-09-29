import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final VideoPlayerController _controller =
      VideoPlayerController.asset('assets/gal_gadot.mp4')
        ..initialize()
        ..setLooping(true)
        ..play();

  bool showControlPanel = false;
  Timer? timer;

  @override
  void dispose() {
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
              child: GestureDetector(
                  onTap: () {
                    if (!showControlPanel) {
                      setState(() {
                        showControlPanel = true;
                      });
                      initControlPanelTimer();
                    }
                  },
                  child: VideoPlayer(_controller))),
          if (showControlPanel)
            VideoControlPanel(
              controller: _controller,
              gestureTapCallback: () {
                setState(() {
                  showControlPanel = false;
                });
                timer?.cancel();
              },
            ),
        ],
      ),
    );
  }

  void initControlPanelTimer() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 5), () {
      setState(() {
        showControlPanel = false;
      });
    });
  }
}

class VideoControlPanel extends StatefulWidget {
  const VideoControlPanel({
    super.key,
    required VideoPlayerController controller,
    required this.gestureTapCallback,
  }) : _controller = controller;

  final VideoPlayerController _controller;
  final GestureTapCallback gestureTapCallback;

  @override
  State<VideoControlPanel> createState() => _VideoControlPanelState();
}

class _VideoControlPanelState extends State<VideoControlPanel> {
  Timer? timer;
  @override
  void initState() {
    timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.gestureTapCallback,
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          'assets/gal_gadot.jpg',
                          width: 60,
                        )),
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gal Gadot',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          Text('@gal_gadot',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12))
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wonder Woman',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    const Text('Dan Dan Dan',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(
                      height: 16,
                    ),
                    VideoProgressIndicator(
                      widget._controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                          playedColor: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.3)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget._controller.value.position
                                .toMinutesSeconds(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget._controller.value.duration
                                .toMinutesSeconds(),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            widget._controller.seekTo(Duration(
                                milliseconds: widget._controller.value.position
                                        .inMilliseconds -
                                    5000));
                          },
                          icon: const Icon(
                            CupertinoIcons.backward_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        IconButton(
                          onPressed: () {
                            if (widget._controller.value.isPlaying) {
                              widget._controller.pause();
                              setState(() {});
                            } else {
                              widget._controller.play();
                              setState(() {});
                            }
                          },
                          icon: Icon(
                            widget._controller.value.isPlaying
                                ? CupertinoIcons.pause_circle_fill
                                : CupertinoIcons.play_circle_fill,
                            color: Colors.white,
                            size: 56,
                          ),
                        ),
                        const SizedBox(
                          width: 24,
                        ),
                        IconButton(
                          onPressed: () {
                            widget._controller.seekTo(Duration(
                                seconds: widget
                                        ._controller.value.position.inSeconds +
                                    5));
                          },
                          icon: const Icon(
                            CupertinoIcons.forward_fill,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension DurationExtensions on Duration {
  String toHoursMinutes() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    return '${_toTwoDigits(inHours)}:$twoDigitMinutes';
  }

  String toHoursMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String towDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return '${_toTwoDigits(inHours)}:$twoDigitMinutes: $towDigitSeconds';
  }

  String toMinutesSeconds() {
    String twoDigitMinutes = _toTwoDigits(inMinutes.remainder(60));
    String twoDigitSeconds = _toTwoDigits(inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  String _toTwoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
