import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/forum.dart';

class ForumService {
  final _supabase = Supabase.instance.client;

  Stream<List<ForumPost>> subscribeToPosts() {
    return _supabase
        .from('forum_posts')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .map((data) => data.map((json) => ForumPost.fromJson(json)).toList());
  }

  Future<void> addPost(String content, String authorId, String authorName, String role, {List<String>? mentions, String? authorPhoto}) async {
    final extractedMentions = mentions ?? RegExp(r'@(\w+)').allMatches(content).map((m) => m.group(1)!).toList();
    
    // Explicitly using author_photo column if it exists, defaulting to dicebear SVG
    final photo = authorPhoto ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$authorName';

    await _supabase.from('forum_posts').insert({
      'author_id': authorId,
      'author_name': authorName,
      'author_role': role,
      'author_photo': photo,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      'likes': [],
      'replies': [],
      'mentions': extractedMentions,
      'moderation_status': 'approved',
      'reported_by': [],
    });
  }

  Future<void> likePost(String postId, String userId) async {
    final response = await _supabase
        .from('forum_posts')
        .select('likes')
        .eq('id', postId)
        .single();
    
    List<String> likes = List<String>.from(response['likes'] ?? []);
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }

    await _supabase
        .from('forum_posts')
        .update({'likes': likes})
        .eq('id', postId);
  }

  Future<void> deletePost(String postId) async {
    await _supabase.from('forum_posts').delete().eq('id', postId);
  }

  Future<void> addReply(String postId, String content, String authorId, String authorName, String role) async {
    final response = await _supabase
        .from('forum_posts')
        .select('replies')
        .eq('id', postId)
        .single();
    
    List<dynamic> replies = List.from(response['replies'] ?? []);
    replies.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'author_id': authorId,
      'author_name': authorName,
      'author_role': role,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _supabase
        .from('forum_posts')
        .update({'replies': replies})
        .eq('id', postId);
  }

  Future<void> flagPost(String postId, String userId) async {
    final response = await _supabase.from('forum_posts').select('reported_by').eq('id', postId).single();
    List<String> reporters = List<String>.from(response['reported_by'] ?? []);
    if (!reporters.contains(userId)) {
      reporters.add(userId);
      // Automatically hide if community threshold is exceeded.
      String status = reporters.length >= 3 ? 'hidden' : 'approved';
      await _supabase.from('forum_posts').update({
        'reported_by': reporters,
        'moderation_status': status,
      }).eq('id', postId);
    }
  }

  Future<void> approvePost(String postId) async {
    await _supabase.from('forum_posts').update({
      'moderation_status': 'approved',
      'reported_by': [], // Clear reporters on approval
    }).eq('id', postId);
  }
}
