import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam.dart';

class OfflineService {
  final _examsBox = Hive.box<String>('cached_exams');
  final _syncBox = Hive.box<String>('pending_sync_queue');
  final _supabase = Supabase.instance.client;

  Future<void> cacheExam(String examId, List<Question> questions) async {
    final jsonList = questions.map((q) => q.toJson()).toList();
    await _examsBox.put(examId, jsonEncode(jsonList));
  }

  List<Question>? getCachedExam(String examId) {
    if (!_examsBox.containsKey(examId)) return null;
    final String data = _examsBox.get(examId)!;
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((q) => Question.fromJson(q)).toList();
  }

  Future<void> queueAttemptSync(Map<String, dynamic> attemptData) async {
    final List<dynamic> queue = _getSyncQueue();
    queue.add(attemptData);
    await _syncBox.put('attempts', jsonEncode(queue));
    _trySync();
  }

  List<dynamic> _getSyncQueue() {
    if (!_syncBox.containsKey('attempts')) return [];
    return jsonDecode(_syncBox.get('attempts')!);
  }

  Future<void> _trySync() async {
    final queue = _getSyncQueue();
    if (queue.isEmpty) return;

    try {
      for (var attempt in queue) {
         await _supabase.from('results').insert(attempt);
      }
      await _syncBox.put('attempts', jsonEncode([]));
    } catch (e) {
      // Silently fail and preserve the queue for the next connectivity event
    }
  }

  void startNetworkListener() {
    // connectivity logic removed for web build stability
  }
}
