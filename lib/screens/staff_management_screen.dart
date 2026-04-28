import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/glass_theme.dart';
import '../services/user_service.dart';

class StaffManagementScreen extends StatelessWidget {
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Staff Management', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Provision and manage administrative accounts', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
              IconButton(
                icon: Icon(LucideIcons.userPlus, color: GlassTheme.primaryColor, size: 28), 
                onPressed: () => _showAddStaffModal(context),
              ),
            ],
          ),
          SizedBox(height: 30),
          _buildStaffGrid(),
        ],
      ),
    );
  }

  void _showAddStaffModal(BuildContext context) {
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    String _selectedRole = 'teacher';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: GlassTheme.glassWrapper(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Staff Member', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                _buildField('Full Name', _nameController, LucideIcons.user),
                _buildField('Email Address', _emailController, LucideIcons.mail),
                _buildField('Password', _passwordController, LucideIcons.lock, obscure: true),
                SizedBox(height: 16),
                Text('System Role', style: TextStyle(color: Colors.white70, fontSize: 12)),
                SizedBox(height: 8),
                Row(
                  children: [
                    _roleChip('teacher', 'Teacher', _selectedRole, (r) => setModalState(() => _selectedRole = r)),
                    SizedBox(width: 8),
                    _roleChip('management', 'Management', _selectedRole, (r) => setModalState(() => _selectedRole = r)),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white54))),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) return;
                        try {
                          await _userService.adminCreateUser(_emailController.text.trim(), _passwordController.text, _nameController.text.trim(), _selectedRole);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Staff provisioned! 🚀')));
                          }
                        } catch (e) {
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryColor),
                      child: Text('Provision Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white60),
          prefixIcon: Icon(icon, color: Colors.white38, size: 20),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GlassTheme.primaryColor)),
        ),
      ),
    );
  }

  Widget _roleChip(String value, String label, String current, Function(String) onSelect) {
    bool isSelected = value == current;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GlassTheme.primaryColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStaffGrid() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _userService.subscribeToStaff(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final staff = snapshot.data?.where((u) => u['role'] == 'management').toList() ?? [];

        if (staff.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Text('No administrative staff found', style: TextStyle(color: Colors.white38)),
            ),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: staff.length,
          itemBuilder: (context, index) {
            final member = staff[index];
            return GlassTheme.glassWrapper(
              padding: EdgeInsets.all(16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25, 
                        backgroundColor: Colors.white12, 
                        child: Icon(LucideIcons.shieldCheck, color: GlassTheme.primaryColor)
                      ),
                      SizedBox(height: 12),
                      Text(
                        member['name'] ?? 'Unknown', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        member['email'] ?? '', 
                        style: TextStyle(color: Colors.white38, fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Positioned(
                    top: -16,
                    right: -16,
                    child: PopupMenuButton(
                      icon: Icon(LucideIcons.moreVertical, color: Colors.white38, size: 18),
                      itemBuilder: (context) => [
                        if (member['status'] != 'approved')
                          PopupMenuItem(
                            child: Text('Approve Account', style: TextStyle(color: Colors.greenAccent)),
                            onTap: () => _userService.updateUserStatus(member['id'], 'approved'),
                          ),
                        if (member['status'] == 'approved')
                          PopupMenuItem(
                            child: Text('Disable Account', style: TextStyle(color: Colors.orangeAccent)),
                            onTap: () => _userService.updateUserStatus(member['id'], 'disabled'),
                          ),
                        PopupMenuItem(
                          child: Text('Change Password', style: TextStyle(color: Colors.blueAccent)),
                          onTap: () {
                            Future.delayed(Duration(milliseconds: 100), () => _showChangePasswordDialog(context, member['id'], member['name'] ?? 'Staff'));
                          },
                        ),
                        PopupMenuItem(
                          child: Text('Delete Record', style: TextStyle(color: Colors.redAccent)),
                          onTap: () => _userService.deleteUser(member['id']),
                        ),
                      ],
                    ),
                  ),
                ],
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
