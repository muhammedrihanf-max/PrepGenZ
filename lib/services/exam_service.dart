import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam.dart';

class ExamService {
  final _supabase = Supabase.instance.client;

  Future<List<ExamMetadata>> getAllExams() async {
    final response = await _supabase
        .from('exams')
        .select('id, title, subject, grade, question_count, updated_at')
        .order('updated_at', ascending: false);
    
    return (response as List).map((e) => ExamMetadata.fromSupabase(e)).toList();
  }

  Stream<List<ExamMetadata>> subscribeToExams() {
    return _supabase
        .from('exams')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) => data.map((e) => ExamMetadata.fromSupabase(e)).toList());
  }

  Future<void> saveExam({
    required String id,
    required String title,
    required String subject,
    required String grade,
    required List<Question> questions,
  }) async {
    await _supabase.from('exams').upsert({
      'id': id,
      'title': title,
      'subject': subject,
      'grade': grade,
      'question_count': questions.length,
      'questions': questions.map((q) => q.toJson()).toList(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> deleteExam(String id) async {
    await _supabase.from('exams').delete().eq('id', id);
  }

  Future<List<Question>> getQuestionsByYear(String year) async {
    final response = await _supabase
        .from('exams')
        .select('questions')
        .eq('id', year)
        .single();
    
    final List<dynamic> questionsJson = response['questions'] as List<dynamic>;
    return questionsJson.map((q) => Question.fromJson(q)).toList();
  }

  Future<void> saveExamResult({
    required String studentId,
    required String examName,
    required int score,
    String? studentName,
  }) async {
    await _supabase.from('results').insert({
      'student_id': studentId,
      'student_name': studentName,
      'exam_name': examName,
      'score': score,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> getStudentPerformance(String studentId) async {
    final response = await _supabase
        .from('results')
        .select('*')
        .eq('student_id', studentId)
        .order('created_at', ascending: false)
        .limit(20);

    final results = response as List;
    
    // Replicate React history mapping
    final history = results.map((r) => {
      'date': DateTime.parse(r['created_at']).toIso8601String(), // Will format in UI
      'score': r['score'],
    }).toList().reversed.toList();

    // Replicate Topic Performance logic
    final Map<String, List<int>> topicMap = {};
    for (var r in results) {
      final topic = r['exam_name'] ?? 'General';
      topicMap.putIfAbsent(topic, () => []).add(r['score'] as int);
    }

    final topics = topicMap.entries.map((e) {
      final sum = e.value.reduce((a, b) => a + b);
      return {
        'subject': e.key,
        'score': (sum / e.value.length).round(),
        'fullMark': 100,
      };
    }).toList();

    return {'history': history, 'topics': topics};
  }

  Future<Map<String, dynamic>> getGlobalStats() async {
    final studentCountRes = await _supabase
        .from('profiles')
        .select('*')
        .eq('role', 'student')
        .count(CountOption.exact);

    final examCountRes = await _supabase
        .from('exams')
        .select('*')
        .count(CountOption.exact);

    final resultsRes = await _supabase
        .from('results')
        .select('score');

    final results = resultsRes as List;
    final totalResults = results.length;
    int avgScore = 0;
    if (totalResults > 0) {
      final sum = results.fold(0, (acc, r) => acc + (r['score'] as int));
      avgScore = (sum / totalResults).round();
    }

    return {
      'studentCount': studentCountRes.count,
      'examCount': examCountRes.count,
      'avgScore': '$avgScore%',
      'activeAttempts': totalResults,
    };
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await _supabase
        .from('results')
        .select('student_id, student_name, score')
        .order('score', ascending: false);
    
    final results = response as List;
    final Map<String, Map<String, dynamic>> studentBest = {};
    
    for (var r in results) {
      final sid = r['student_id'];
      if (!studentBest.containsKey(sid) || (studentBest[sid]!['score'] as int) < (r['score'] as int)) {
        studentBest[sid] = {
          'id': sid,
          'name': r['student_name'] ?? 'Student',
          'score': r['score'],
          'avatar_seed': sid,
        };
      }
    }

    final sorted = studentBest.values.toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    
    return sorted.take(15).toList();
  }

  Future<List<Map<String, dynamic>>> getRecentActivity() async {
    final response = await _supabase
        .from('results')
        .select('*')
        .order('created_at', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }  Future<String> exportResultsToCSV() async {
    final response = await _supabase
        .from('results')
        .select('student_name, exam_name, score, created_at')
        .order('created_at', ascending: false);
    
    final results = response as List;
    final buffer = StringBuffer();
    buffer.writeln('Student Name,Exam Name,Score,Date');
    
    for (var r in results) {
      final name = r['student_name'] ?? 'Student';
      final exam = r['exam_name'] ?? 'Exam';
      final score = '${r['score']}%';
      final date = DateTime.parse(r['created_at']).toLocal().toString().split('.')[0];
      buffer.writeln('$name,$exam,$score,$date');
    }
    
    return buffer.toString();
  }
}
