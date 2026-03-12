// Commit 23: 코치(관리자) 대시보드 기본 UI (Flutter Web 지원)

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../services/firestore_feedback_repository.dart';
import 'coach_session_review_screen.dart';

/// 코치 화면에서 보여줄 세션(더미) 아이템
class CoachSessionItem {
  const CoachSessionItem({
    required this.sessionId,
    required this.userEmail,
    required this.exerciseName,
  });

  final String sessionId;
  final String userEmail;
  final String exerciseName;
}

class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({super.key, this.items});

  final List<CoachSessionItem>? items;

  static const _dummyItems = <CoachSessionItem>[
    CoachSessionItem(
      sessionId: 'demo-1',
      userEmail: 'demo1@example.com',
      exerciseName: '스쿼트',
    ),
    CoachSessionItem(
      sessionId: 'demo-2',
      userEmail: 'demo2@example.com',
      exerciseName: '데드리프트',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final data = items ?? _dummyItems;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final list = _SessionList(items: data);
        final side = _SidePanel(items: data);

        return Scaffold(
          appBar: AppBar(
            title: const Text('코치 대시보드'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: isWide
              ? Row(
                  children: [
                    Expanded(flex: 2, child: list),
                    const VerticalDivider(width: 1),
                    Expanded(flex: 1, child: side),
                  ],
                )
              : list,
        );
      },
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.items});

  final List<CoachSessionItem> items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            title: Text(item.userEmail),
            subtitle: Text('운동: ${item.exerciseName}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CoachSessionReviewScreen(
                    item: item,
                    feedbackRepository: Firebase.apps.isEmpty
                        ? null
                        : FirestoreFeedbackRepository(),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.items});

  final List<CoachSessionItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '요약',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text('세션 수: ${items.length}'),
          const SizedBox(height: 24),
          Text(
            '다음 단계(Commit 24~26)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('- 영상 재생 + 피드백 입력 UI'),
          const Text('- Firestore 저장'),
        ],
      ),
    );
  }
}

