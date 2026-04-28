import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';
import '../services/auth_provider.dart';
import '../services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  String _selectedGender = 'other';
  String _selectedAvatar = '';
  bool _isSaving = false;

  final Map<String, List<String>> _avatars = {
    'male': [
      'https://api.dicebear.com/7.x/avataaars/png?seed=Felix',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Max',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Jack',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Oliver',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Leo',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Arlo',
    ],
    'female': [
      'https://api.dicebear.com/7.x/avataaars/png?seed=Sasha',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Bella',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Willow',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Lily',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Zoe',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Maya',
    ],
    'other': [
      'https://api.dicebear.com/7.x/avataaars/png?seed=Shadow',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Zen',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Nova',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Spark',
      'https://api.dicebear.com/7.x/avataaars/png?seed=Cosmo',
      'https://api.dicebear.com/7.x/avataaars/png?seed=River',
    ]
  };

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final profile = auth.user?.userMetadata;
    _nameController.text = profile?['name'] ?? '';
    _selectedGender = profile?['gender'] ?? 'other';
    _selectedAvatar = profile?['photo_url'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatarSection(),
            SizedBox(height: 32),
            _buildFormSection(),
            SizedBox(height: 32),
            _buildAvatarGallery(),
            SizedBox(height: 32),
            _buildPasswordSection(),
            SizedBox(height: 48),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GlassTheme.primaryColor, width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white10,
              backgroundImage: _selectedAvatar.isNotEmpty ? NetworkImage(_selectedAvatar) : null,
              child: _selectedAvatar.isEmpty ? Icon(LucideIcons.user, size: 40, color: Colors.white24) : null,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: GlassTheme.primaryColor, shape: BoxShape.circle),
            child: Icon(LucideIcons.camera, color: Colors.white, size: 20),
          ),
        ],
      ),
    ).animate().scale(duration: 400.ms);
  }

  Widget _buildFormSection() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Display Name', _nameController, LucideIcons.user),
          SizedBox(height: 20),
          _buildGenderSelector(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isPassword = false, bool disabled = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        TextField(
          controller: controller,
          obscureText: isPassword,
          enabled: !disabled,
          style: TextStyle(color: disabled ? Colors.white24 : Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white38, size: 18),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white12)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: GlassTheme.primaryColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('GENDER', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        SizedBox(height: 12),
        Row(
          children: ['male', 'female', 'other'].map((gender) {
            bool isSelected = _selectedGender == gender;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? GlassTheme.primaryColor.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? GlassTheme.primaryColor : Colors.transparent),
                  ),
                  child: Center(
                    child: Text(
                      gender[0].toUpperCase() + gender.substring(1),
                      style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvatarGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK AVATARS', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
        SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _avatars[_selectedGender]?.length ?? 0,
          itemBuilder: (context, index) {
            final url = _avatars[_selectedGender]![index];
            bool isSelected = _selectedAvatar == url;
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = url),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? GlassTheme.primaryColor : Colors.transparent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(url),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CHANGE PASSWORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          _buildTextField('New Password', _passController, LucideIcons.lock, isPassword: true),
          SizedBox(height: 16),
          _buildTextField('Confirm Password', _confirmPassController, LucideIcons.lock, isPassword: true),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassTheme.primaryColor,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving 
          ? CircularProgressIndicator(color: Colors.white) 
          : Text('Save Profile Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Future<void> _saveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) return;

    setState(() => _isSaving = true);

    try {
      final userService = UserService();
      
      // Update DB Profiles table
      await userService.updateProfile(auth.user!.id, {
        'name': _nameController.text.trim(),
        'gender': _selectedGender,
        'photo_url': _selectedAvatar,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Update Auth Metadata (for local reflection)
      // Note: Supabase.instance.client.auth.updateUser only allows certain keys in userMetadata
      // but 'name', 'gender', 'photo_url' are standard.
      // However, we primarily care about the public.profiles table.

      if (_passController.text.isNotEmpty) {
        if (_passController.text == _confirmPassController.text) {
          try {
            await userService.updatePassword(_passController.text);
          } on AuthException catch (ae) {
            // Ignore "same password" error as it's not a critical failure for profile updates
            if (ae.code != 'same_password') rethrow;
          }
        } else {
          throw 'Passwords do not match';
        }
      }

      // Refresh local auth state to reflect changes
      await auth.refreshUser();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully! ✨')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
