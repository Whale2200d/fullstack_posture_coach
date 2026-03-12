// Commit 24: 코치 피드백 입력 UI (좋아요/싫어요 버튼)

import 'package:flutter/material.dart';

import 'coach_dashboard_screen.dart';
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
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('영상 미리보기 (Commit 25에서 연결)'),
            ),
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

