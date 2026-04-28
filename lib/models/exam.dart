class Question {
  final String text;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String? image;

  Question({
    required this.text,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.image,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? 0,
      explanation: json['explanation'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'options': options,
      'correctAnswer': correctAnswer,
      'explanation': explanation,
      'image': image,
    };
  }
}

class ExamMetadata {
  final String id;
  final String title;
  final String subject;
  final String grade;
  final int questionCount;
  final DateTime updatedAt;

  ExamMetadata({
    required this.id,
    required this.title,
    required this.subject,
    required this.grade,
    required this.questionCount,
    required this.updatedAt,
  });

  factory ExamMetadata.fromSupabase(Map<String, dynamic> json) {
    return ExamMetadata(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      grade: json['grade'] ?? '',
      questionCount: json['question_count'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
