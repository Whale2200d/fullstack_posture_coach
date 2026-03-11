import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({super.key, required this.file});

  final File file;

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _controller;
  Future<void>? _initializeFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file);
    _initializeFuture = _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('촬영 영상 미리보기'),
      ),
      body: FutureBuilder(
        future: _initializeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio == 0
                  ? 9 / 16
                  : _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
          setState(() {});
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

