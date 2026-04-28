import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _role;
  bool _isLoading = true;

  User? get user => _user;
  String get role => _role ?? 'student';
  bool get isLoading => _isLoading;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final session = Supabase.instance.client.auth.currentSession;
    _user = session?.user;
    if (_user != null) await _fetchRole();
    _isLoading = false;
    notifyListeners();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      _user = data.session?.user;
      if (_user != null) {
        await _fetchRole();
      } else {
        _role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchRole() async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role, status')
          .eq('id', _user!.id)
          .single();
          
      if (data['role'] == 'student' && data['status'] == 'pending') {
        _user = null;
        _role = null;
      } else {
        _role = data['role'];
      }
    } catch (e) {
      _role = 'student';
    }
  }

  Future<void> signIn(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('role, status')
            .eq('id', response.user!.id)
            .single();
            
        if (data['role'] == 'student' && (data['status'] == 'pending' || data['status'] == null)) {
          await Supabase.instance.client.auth.signOut();
          throw Exception('Account pending approval. Please wait for a teacher to approve your account.');
        }
      } catch (e) {
        if (e.toString().contains('pending approval')) rethrow;
      }
    }
  }

  Future<void> signUp(String email, String password, String name, String role, {String? staffCode}) async {
    const String correctStaffCode = 'J3lly22fish@';

    if (role != 'student') {
      if (staffCode == null || staffCode.isEmpty) {
        throw Exception('Staff access code is required for this role');
      }
      if (staffCode != correctStaffCode) {
        throw Exception('Invalid staff access code');
      }
    }

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );

    if (response.user != null) {
      // Create profile record mirroring React implementation
      await Supabase.instance.client.from('profiles').insert({
        'id': response.user!.id,
        'name': name,
        'email': email,
        'role': role,
        'status': role == 'student' ? 'pending' : 'active',
        'avatar_seed': name,
        'joined_date': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  Future<void> refreshUser() async {
    final response = await Supabase.instance.client.auth.getUser();
    _user = response.user;
    if (_user != null) await _fetchRole();
    notifyListeners();
  }
}
