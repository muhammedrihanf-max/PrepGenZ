import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/glass_theme.dart';
import '../services/user_service.dart';

class TeacherManagementScreen extends StatelessWidget {
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teacher Management', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Manage faculty departments and information', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 30),
          _buildTeacherList(),
        ],
      ),
    );
  }

  Widget _buildTeacherList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _userService.subscribeToStaff(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        final teachers = snapshot.data?.where((u) => u['role'] == 'teacher').toList() ?? [];

        if (teachers.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text('No teachers found', style: TextStyle(color: Colors.white38)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: GlassTheme.glassWrapper(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: GlassTheme.primaryColor.withOpacity(0.2), 
                      child: Text(
                        (teacher['name'] ?? 'T').substring(0, 1), 
                        style: TextStyle(color: Colors.white)
                      )
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(teacher['name'] ?? 'Unknown Teacher', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(teacher['email'] ?? '', style: TextStyle(color: GlassTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    IconButton(icon: Icon(LucideIcons.mail, color: Colors.white38, size: 18), onPressed: () {}),
                    PopupMenuButton(
                      icon: Icon(LucideIcons.moreVertical, color: Colors.white38, size: 18),
                      itemBuilder: (context) => [
                        if (teacher['status'] != 'approved')
                          PopupMenuItem(
                            child: Text('Approve Account', style: TextStyle(color: Colors.greenAccent)),
                            onTap: () => _userService.updateUserStatus(teacher['id'], 'approved'),
                          ),
                        if (teacher['status'] == 'approved')
                          PopupMenuItem(
                            child: Text('Disable Account', style: TextStyle(color: Colors.orangeAccent)),
                            onTap: () => _userService.updateUserStatus(teacher['id'], 'disabled'),
                          ),
                        PopupMenuItem(
                          child: Text('Change Password', style: TextStyle(color: Colors.blueAccent)),
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 100), () => _showChangePasswordDialog(context, teacher['id'], teacher['name'] ?? 'Teacher'));
                          },
                        ),
                        PopupMenuItem(
                          child: Text('Delete Record', style: TextStyle(color: Colors.redAccent)),
                          onTap: () => _userService.deleteUser(teacher['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  void _showChangePasswordDialog(BuildContext context, String uid, String name) {
    final _pwdController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        title: Text('Change Password for $name', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: _pwdController,
          obscureText: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'New Password...', hintStyle: TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              if (_pwdController.text.trim().isEmpty) return;
              try {
                await _userService.adminUpdateUserPassword(uid, _pwdController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Password updated successfully!')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
              }
            },
            child: Text('Update'),
            style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
