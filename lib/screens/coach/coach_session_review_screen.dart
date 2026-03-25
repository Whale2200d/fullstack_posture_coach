// Commit 24: 코치 피드백 입력 UI (좋아요/싫어요 버튼)

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/coach_session_item.dart';
import '../../services/feedback_repository.dart';
import '../../services/notification_service.dart';

enum CoachFeedbackChoice { none, like, dislike }

class CoachSessionReviewScreen extends StatefulWidget {
  const CoachSessionReviewScreen({
    super.key,
    required this.item,
    this.feedbackRepository,
    this.notificationService,
  });

  final CoachSessionItem item;
  final IFeedbackRepository? feedbackRepository;
  final INotificationService? notificationService;

  @override
  State<CoachSessionReviewScreen> createState() =>
      _CoachSessionReviewScreenState();
}

class _CoachSessionReviewScreenState extends State<CoachSessionReviewScreen> {
  CoachFeedbackChoice _choice = CoachFeedbackChoice.none;
  double _score = 3;
  VideoPlayerController? _videoController;
  Future<void>? _videoInitFuture;
  String? _videoInitError;

  @override
  void initState() {
    super.initState();
    _setupVideoIfNeeded();
  }

  void _setupVideoIfNeeded() {
    final url = widget.item.videoDownloadUrl;
    if (url == null || url.isEmpty) {
      return;
    }
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _videoController = controller;
      _videoInitFuture = controller.initialize().then((_) {
        if (mounted) setState(() {});
      }).catchError((Object e) {
        if (mounted) {
          setState(() {
            _videoInitError = '$e';
          });
        }
      });
    } catch (e) {
      _videoInitError = '$e';
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _toggle(CoachFeedbackChoice next) {
    setState(() {
      _choice = (_choice == next) ? CoachFeedbackChoice.none : next;
    });
  }

  String get _choiceLabel {
    switch (_choice) {
      case CoachFeedbackChoice.like:
        return '좋아요';
      case CoachFeedbackChoice.dislike:
        return '싫어요';
      case CoachFeedbackChoice.none:
        return '없음';
    }
  }

  bool? get _isPositive {
    switch (_choice) {
      case CoachFeedbackChoice.like:
        return true;
      case CoachFeedbackChoice.dislike:
        return false;
      case CoachFeedbackChoice.none:
        return null;
    }
  }

  Future<void> _onSave() async {
    final repo = widget.feedbackRepository;
    if (repo == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('피드백 저장소가 설정되지 않았습니다.')),
      );
      return;
    }

    final data = FeedbackData(
      sessionId: widget.item.sessionId,
      userEmail: widget.item.userEmail,
      exerciseName: widget.item.exerciseName,
      isPositive: _isPositive,
      score: _score.toInt(),
    );
    await repo.saveFeedback(data);

    final notifier = widget.notificationService;
    if (notifier != null) {
      await notifier.sendLocal(
        '피드백 저장',
        '세션 ${widget.item.sessionId} 피드백이 저장되었습니다',
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('피드백이 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        title: const Text('세션 리뷰'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '사용자: ${item.userEmail}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text('운동: ${item.exerciseName}'),
          const SizedBox(height: 16),
          _SessionVideoSection(
            downloadUrl: item.videoDownloadUrl,
            controller: _videoController,
            initFuture: _videoInitFuture,
            initError: _videoInitError,
            onTogglePlay: () {
              final c = _videoController;
              if (c == null || !c.value.isInitialized) return;
              setState(() {
                if (c.value.isPlaying) {
                  c.pause();
                } else {
                  c.play();
                }
              });
            },
          ),
          const SizedBox(height: 16),
          Text('선택: $_choiceLabel'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: KeyedSubtree(
                  key: const Key('feedback_like'),
                  child: FilledButton.icon(
                    onPressed: () => _toggle(CoachFeedbackChoice.like),
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('좋아요'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: KeyedSubtree(
                  key: const Key('feedback_dislike'),
                  child: FilledButton.icon(
                    onPressed: () => _toggle(CoachFeedbackChoice.dislike),
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('싫어요'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('점수: ${_score.toInt()}'),
          Slider(
            value: _score,
            min: 1,
            max: 5,
            divisions: 4,
            label: _score.toInt().toString(),
            onChanged: (v) {
              setState(() {
                _score = v;
              });
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _onSave,
              child: const Text('저장'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionVideoSection extends StatelessWidget {
  const _SessionVideoSection({
    required this.downloadUrl,
    required this.controller,
    required this.initFuture,
    required this.initError,
    required this.onTogglePlay,
  });

  final String? downloadUrl;
  final VideoPlayerController? controller;
  final Future<void>? initFuture;
  final String? initError;
  final VoidCallback onTogglePlay;

  @override
  Widget build(BuildContext context) {
    if (downloadUrl == null || downloadUrl!.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('업로드된 영상 URL이 없습니다.'),
        ),
      );
    }

    if (initError != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          padding: const EdgeInsets.all(12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '영상을 불러오지 못했습니다.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final c = controller;
    if (c == null) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!c.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: FutureBuilder<void>(
          future: initFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('영상 초기화 실패'),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      );
    }

    return AspectRatio(
      aspectRatio: c.value.aspectRatio == 0 ? 16 / 9 : c.value.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(c),
            Positioned(
              bottom: 8,
              child: IconButton.filled(
                onPressed: onTogglePlay,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(
                  c.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

