import 'package:supabase_flutter/supabase_flutter.dart';

class ScoreHistory {
  final String date;
  final int score;
  ScoreHistory(this.date, this.score);
}

class TopicPerformance {
  final String subject;
  final int score;
  final int fullMark;
  TopicPerformance(this.subject, this.score, {this.fullMark = 100});
}

class AnalyticsService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getStudentPerformance(String studentId) async {
    final response = await _supabase
        .from('results')
        .select('*')
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(20);

    final List results = response as List;
    
    // Map history
    final history = results.map((r) {
      final date = DateTime.parse(r['created_at']);
      return ScoreHistory("${date.month}/${date.day}", r['score'] as int);
    }).toList().reversed.toList();

    // Calculate Topic Performance
    final Map<String, List<int>> topicMap = {};
    for (var r in results) {
      final topic = r['exam_name'] ?? 'General';
      topicMap.putIfAbsent(topic, () => []).add(r['score'] as int);
    }

    final topics = topicMap.entries.map((e) {
      final avg = e.value.reduce((a, b) => a + b) ~/ e.value.length;
      return TopicPerformance(e.key, avg);
    }).toList();

    if (topics.isEmpty) {
      topics.add(TopicPerformance('No Exams Yet', 0));
    }

    return {'history': history, 'topics': topics};
  }
}
