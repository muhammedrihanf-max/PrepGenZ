import 'package:supabase_flutter/supabase_flutter.dart';

class SupportService {
  final _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> subscribeToInquiries(String userId, String role) {
    if (role == 'student') {
      return _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('student_id', userId)
          .order('timestamp', ascending: false)
          .map((data) => List<Map<String, dynamic>>.from(data));
    }
    
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> createInquiry({
    required String studentId,
    required String studentName,
    required String message,
    String? fromPhoto,
    String? attachment,
  }) async {
    await _supabase.from('notifications').insert({
      'type': 'question',
      'student_id': studentId,
      'from_name': studentName,
      'from_photo': fromPhoto,
      'message': message,
      'attachment': attachment,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
      'status': 'open',
    });
  }

  Future<void> replyToInquiry(String inquiryId, String message, String authorName, String? authorPhoto) async {
    await _supabase.from('notifications').update({
      'reply': {
        'message': message,
        'author': authorName,
        'author_photo': authorPhoto,
        'timestamp': DateTime.now().toIso8601String(),
      },
      'read': true,
      'status': 'replied',
    }).eq('id', inquiryId);
  }

  Future<void> sendBroadcast(String message, String authorName, {String? fromPhoto}) async {
    await _supabase.from('notifications').insert({
      'type': 'system',
      'from_name': authorName,
      'from_photo': fromPhoto,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'is_broadcast': true,
      'read': false,
    });
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String userId, String role) {
    var query = _supabase.from('notifications').stream(primaryKey: ['id']);
    
    if (role == 'student') {
      // Students see their own inquiries AND global broadcasts
      return query
          .order('timestamp', ascending: false)
          .map((data) => data.where((n) => n['student_id'] == userId || n['is_broadcast'] == true).toList());
    }
    
    // Staff see all inquiries
    return query.order('timestamp', ascending: false).map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> markAllAsRead(String userId, String role) async {
    if (role == 'student') {
      await _supabase.from('notifications').update({'read': true}).eq('student_id', userId);
    } else {
      await _supabase.from('notifications').update({'read': true}).eq('type', 'question');
    }
  }

  Future<void> deleteNotification(String id) async {
    await _supabase.from('notifications').delete().eq('id', id);
  }

  Future<void> clearAllNotifications(String userId, String role) async {
    if (role == 'student') {
      await _supabase.from('notifications').delete().eq('student_id', userId);
    } else {
      await _supabase.from('notifications').delete().eq('type', 'question');
    }
  }

  Stream<int> getUnreadInquiriesCount() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('type', 'question')
        .map((data) => data.where((n) => n['read'] == false).length);
  }

  Stream<int> getUnreadNotificationsCount(String userId, String role) {
    return getNotifications(userId, role).map((data) => data.where((n) => n['read'] == false).length);
  }

  Stream<Map<String, dynamic>?> getLatestBroadcast() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('is_broadcast', true)
        .order('timestamp', ascending: false)
        .limit(1)
        .map((data) => data.isNotEmpty ? data.first : null);
  }
}
