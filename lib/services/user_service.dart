import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final _supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> subscribeToStudents() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'student')
        .order('joined_date', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Stream<List<Map<String, dynamic>>> subscribeToStaff() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .order('joined_date', ascending: false)
        .map((data) => data
            .where((u) => u['role'] == 'teacher' || u['role'] == 'management')
            .map((u) => Map<String, dynamic>.from(u))
            .toList());
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _supabase.rpc('admin_update_user_status', params: {
      'target_user_id': uid,
      'new_status': status,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _supabase.rpc('admin_delete_user', params: {
      'target_user_id': uid,
    });
  }

  Future<List<Map<String, dynamic>>> getStaffProfiles() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .or('role.eq.teacher,role.eq.management');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    // 1. Update public.profiles table
    await _supabase
        .from('profiles')
        .update(data)
        .eq('id', userId);

    // 2. Sync to Auth Metadata so it reflects in auth state without re-login
    await _supabase.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> adminUpdateUserPassword(String targetUid, String newPassword) async {
    await _supabase.rpc('update_user_password', params: {
      'target_user_id': targetUid,
      'new_password': newPassword,
    });
  }

  Future<void> adminCreateUser(String email, String password, String name, String role) async {
    await _supabase.rpc('admin_create_user', params: {
      'new_email': email,
      'new_password': password,
      'user_name': name,
      'user_role': role,
    });
  }
}
