import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/offline_upload_queue.dart';
import '../services/session_repository.dart';
import '../services/video_upload_service.dart';

class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({
    super.key,
    required this.file,
    this.uploader,
    this.offlineQueue,
    this.sessionRepository,
    this.userEmail,
    this.userId,
    this.exerciseName = 'squat',
  });

  final File file;
  final IVideoUploader? uploader;
  final IOfflineUploadQueue? offlineQueue;
  final ISessionRepository? sessionRepository;
  final String? userEmail;
  final String? userId;
  final String exerciseName;

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late final VideoPlayerController _controller;
  Future<void>? _initializeFuture;
  bool _uploading = false;

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
        actions: [
          TextButton(
            onPressed: _uploading ? null : _onUpload,
            child: _uploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('업로드'),
          ),
        ],
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

  Future<void> _onUpload() async {
    final uploader = widget.uploader;
    if (uploader == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('업로드 기능은 아직 설정되지 않았습니다.')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'videos/$now.mp4';
      final url = await uploader.uploadVideo(
        file: widget.file,
        storagePath: storagePath,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('업로드 완료: $url')),
      );

      final repo = widget.sessionRepository;
      if (repo != null) {
        try {
          await repo.save(
            SessionRecord(
              userEmail: widget.userEmail ?? '',
              exerciseName: widget.exerciseName,
              storagePath: storagePath,
              downloadUrl: url,
              userId: widget.userId,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('세션 기록 저장 실패(업로드는 완료됨): $e')),
          );
        }
      }
    } catch (e) {
      final queue = widget.offlineQueue;
      if (queue != null) {
        await queue.enqueue(widget.file.path);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('업로드 실패: 오프라인 업로드 큐에 저장되었습니다.'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}

