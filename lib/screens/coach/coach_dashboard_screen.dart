// Commit 23: 코치(관리자) 대시보드 기본 UI (Flutter Web 지원)
// Commit 41: Firestore sessions 스트림 연동

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../models/coach_session_item.dart';
import '../../services/firestore_feedback_repository.dart';
import '../../services/firebase_notification_service.dart';
import '../../services/session_list_repository.dart';
import 'coach_session_review_screen.dart';

class CoachDashboardScreen extends StatelessWidget {
  const CoachDashboardScreen({
    super.key,
    this.items,
    this.sessionListRepository,
  });

  /// 수동 주입(테스트·데모). [sessionListRepository]가 있으면 무시된다.
  final List<CoachSessionItem>? items;

  /// Firestore 등에서 세션 목록을 구독할 때 사용.
  final ISessionListRepository? sessionListRepository;

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
    final repo = sessionListRepository;
    if (repo != null) {
      return StreamBuilder<List<CoachSessionItem>>(
        stream: repo.watchRecentSessions(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('코치 대시보드'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('세션 목록을 불러오지 못했습니다: ${snapshot.error}'),
                ),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('코치 대시보드'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data ?? [];
          return _CoachDashboardBody(items: data);
        },
      );
    }

    final data = items ?? _dummyItems;
    return _CoachDashboardBody(items: data);
  }
}

class _CoachDashboardBody extends StatelessWidget {
  const _CoachDashboardBody({required this.items});

  final List<CoachSessionItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final list = _SessionList(items: items);
        final side = _SidePanel(items: items);

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
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('등록된 세션이 없습니다. 사용자가 영상을 업로드하면 여기에 표시됩니다.'),
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            title: Text(item.userEmail.isEmpty ? '(이메일 없음)' : item.userEmail),
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
                    notificationService: Firebase.apps.isEmpty
                        ? null
                        : FirebaseNotificationService(),
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
            'Firestore',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('sessions 컬렉션의 최근 업로드가 목록에 표시됩니다.'),
        ],
      ),
    );
  }
}
