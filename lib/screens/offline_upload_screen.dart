import 'package:flutter/material.dart';

import '../services/offline_upload_queue.dart';
import '../services/offline_upload_retry_service.dart';
import '../services/video_upload_service.dart';

class OfflineUploadScreen extends StatefulWidget {
  const OfflineUploadScreen({
    super.key,
    required this.queue,
    required this.uploader,
  });

  final IOfflineUploadQueue queue;
  final IVideoUploader uploader;

  @override
  State<OfflineUploadScreen> createState() => _OfflineUploadScreenState();
}

class _OfflineUploadScreenState extends State<OfflineUploadScreen> {
  late OfflineUploadRetryService _retryService;
  List<OfflineUploadTask> _pending = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _retryService =
        OfflineUploadRetryService(queue: widget.queue, uploader: widget.uploader);
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() {
      _loading = true;
    });
    final items = await widget.queue.getPending();
    if (!mounted) return;
    setState(() {
      _pending = items;
      _loading = false;
    });
  }

  Future<void> _onRetryAll() async {
    setState(() {
      _loading = true;
    });
    final result = await _retryService.retryAll();
    if (!mounted) return;
    await _loadPending();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '재시도 완료: 총 ${result.total}개, 성공 ${result.succeeded}개, 실패 ${result.failed}개',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오프라인 업로드 관리'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _loadPending,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pending.isEmpty
              ? const Center(
                  child: Text('대기 중인 오프라인 업로드 작업이 없습니다.'),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final task = _pending[index];
                    return ListTile(
                      leading: const Icon(Icons.cloud_upload),
                      title: Text(task.localPath),
                      subtitle: Text(task.createdAt.toIso8601String()),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: _pending.length,
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _loading || _pending.isEmpty ? null : _onRetryAll,
              icon: const Icon(Icons.play_circle),
              label: const Text('전체 다시 업로드'),
            ),
          ),
        ),
      ),
    );
  }
}

