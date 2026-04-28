class ForumPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorRole;
  final String? authorPhoto;
  final String content;
  final DateTime timestamp;
  final List<String> likes;
  final List<ForumReply> replies;
  final List<String> mentions;
  final String moderationStatus;
  final List<String> reportedBy;

  ForumPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorRole,
    this.authorPhoto,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.replies,
    this.mentions = const [],
    this.moderationStatus = 'approved',
    this.reportedBy = const [],
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id']?.toString() ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? '',
      authorRole: json['author_role'],
      authorPhoto: json['author_photo'],
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      likes: List<String>.from(json['likes'] ?? []),
      replies: (json['replies'] as List? ?? []).map((r) => ForumReply.fromJson(r)).toList(),
      mentions: List<String>.from(json['mentions'] ?? []),
      moderationStatus: json['moderation_status'] ?? 'approved',
      reportedBy: List<String>.from(json['reported_by'] ?? []),
    );
  }
}

class ForumReply {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorRole;
  final String? authorPhoto;
  final String content;
  final DateTime timestamp;

  ForumReply({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorRole,
    this.authorPhoto,
    required this.content,
    required this.timestamp,
  });

  factory ForumReply.fromJson(Map<String, dynamic> json) {
    return ForumReply(
      id: json['id']?.toString() ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? '',
      authorRole: json['author_role'],
      authorPhoto: json['author_photo'],
      content: json['content'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}
