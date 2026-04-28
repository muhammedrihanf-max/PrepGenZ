import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/glass_theme.dart';
import '../services/user_service.dart';

class StudentManagementScreen extends StatefulWidget {
  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student Management', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        Text('Review registrations and track progress', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.userPlus, color: GlassTheme.primaryColor, size: 28),
                    onPressed: () => _showAddStudentDialog(),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _buildSearchAndFilters(),
        ),
        SizedBox(height: 20),
        Expanded(child: _buildStudentList()),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: GlassTheme.glassWrapper(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                icon: Icon(LucideIcons.search, color: Colors.white30, size: 18),
                hintText: 'Search students...',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 14),
                border: InputBorder.none,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
        ),
        SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            // Future filter logic
          },
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: GlassTheme.glassDecoration(opacity: 0.1, borderRadius: 12),
            child: Icon(LucideIcons.filter, color: Colors.white70, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _userService.subscribeToStudents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
        }
        var students = snapshot.data ?? [];
        
        // Local filtering
        if (_searchController.text.isNotEmpty) {
          final query = _searchController.text.toLowerCase();
          students = students.where((s) => 
            (s['name']?.toString().toLowerCase().contains(query) ?? false) ||
            (s['email']?.toString().toLowerCase().contains(query) ?? false)
          ).toList();
        }

        if (students.isEmpty) {
          return Center(child: Text('No students found.', style: TextStyle(color: Colors.white38)));
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final status = student['status'] ?? 'pending';
            final isApproved = status == 'active' || status == 'approved';

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: GlassTheme.glassWrapper(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white12, 
                      backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/svg?seed=${student['avatar_seed'] ?? student['id']}'),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student['name'] ?? 'Student', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text(student['email'] ?? '', style: TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              _miniStat(LucideIcons.target, student['avg_score'] ?? '0%'),
                              SizedBox(width: 12),
                              _miniStat(LucideIcons.zap, student['last_exam'] ?? 'No exams'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: !isApproved ? () async {
                            try {
                              await _userService.updateUserStatus(student['id'], 'approved');
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('${student['name']} approved! ✅')));
                            } catch (e) {
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text('Error: $e')));
                            }
                          } : null,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isApproved ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toString().toUpperCase(),
                              style: TextStyle(
                                color: isApproved ? Colors.greenAccent : Colors.orangeAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          icon: Icon(LucideIcons.moreVertical, color: Colors.white24, size: 18),
                          itemBuilder: (context) => [
                            if (!isApproved)
                              PopupMenuItem(
                                child: Text('Approve Account', style: TextStyle(color: Colors.greenAccent)),
                                onTap: () async {
                                  try {
                                    await _userService.updateUserStatus(student['id'], 'active');
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Student approved successfully!')));
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                  }
                                },
                              ),
                            if (isApproved)
                              PopupMenuItem(
                                child: Text('Disable Account', style: TextStyle(color: Colors.orangeAccent)),
                                onTap: () async {
                                  try {
                                    await _userService.updateUserStatus(student['id'], 'disabled');
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account disabled.')));
                                  } catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                  }
                                },
                              ),
                            PopupMenuItem(
                              child: Text('Change Password', style: TextStyle(color: Colors.blueAccent)),
                              onTap: () {
                                // Defer dialog to ensure popup closes smoothly
                                Future.delayed(Duration(milliseconds: 100), () => _showChangePasswordDialog(student['id'], student['name'] ?? 'Student'));
                              },
                            ),
                            PopupMenuItem(
                              child: Text('Delete Record', style: TextStyle(color: Colors.redAccent)),
                              onTap: () async {
                                try {
                                  await _userService.deleteUser(student['id']);
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text('Record deleted.')));
                                } catch (e) {
                                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _miniStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 10, color: GlassTheme.primaryColor),
        SizedBox(width: 4),
        Text(value, style: TextStyle(color: Colors.white38, fontSize: 10)),
      ],
    );
  }

  void _showChangePasswordDialog(String uid, String name) {
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

  void _showAddStudentDialog() {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E2E),
        title: Text('Add New Student', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Full Name...', hintStyle: TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05))),
            SizedBox(height: 12),
            TextField(controller: _emailController, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Email Address...', hintStyle: TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05))),
            SizedBox(height: 12),
            TextField(controller: _passwordController, obscureText: true, style: TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Password...', hintStyle: TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () async {
              if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) return;
              try {
                await _userService.adminCreateUser(_emailController.text.trim(), _passwordController.text, _nameController.text.trim(), 'student');
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Student account created successfully!')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create student: $e')));
              }
            },
            child: Text('Add Student'),
            style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryColor),
          ),

        ],
      ),
    );
  }
}
