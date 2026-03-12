// Commit 30: 오프라인 업로드 큐 – 서비스 인터페이스 및 메모리 구현

import 'dart:math';

class OfflineUploadTask {
  OfflineUploadTask({
    required this.id,
    required this.localPath,
    required this.createdAt,
    this.uploaded = false,
  });

  final String id;
  final String localPath;
  final DateTime createdAt;
  bool uploaded;
}

abstract class IOfflineUploadQueue {
  Future<void> enqueue(String localPath);
  Future<List<OfflineUploadTask>> getPending();
  Future<void> markUploaded(String id);
}

/// 테스트 및 초기 단계에서 사용하는 메모리 기반 큐 구현.
/// 추후 Hive 기반 구현으로 교체하거나 병행할 수 있다.
class MemoryOfflineUploadQueue implements IOfflineUploadQueue {
  final List<OfflineUploadTask> _tasks = [];
  final Random _rand = Random();

  @override
  Future<void> enqueue(String localPath) async {
    final id = '${DateTime.now().millisecondsSinceEpoch}_${_rand.nextInt(1 << 32)}';
    _tasks.add(
      OfflineUploadTask(
        id: id,
        localPath: localPath,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<OfflineUploadTask>> getPending() async {
    return _tasks.where((t) => !t.uploaded).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<void> markUploaded(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tasks[idx].uploaded = true;
  }
}

