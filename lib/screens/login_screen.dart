import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';
import '../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _staffCodeController = TextEditingController();
  String _activeRole = 'student';
  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlassTheme.backgroundColor,
      body: Stack(
        children: [
          // Animated Background Blobs
          _buildBackgroundBlobs(),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHeader(),
                    SizedBox(height: _isLogin ? 40 : 20),
                    _buildAuthCard(),
                    SizedBox(height: 30),
                    _buildFooterActions(),
                    SizedBox(height: 40),
                    _buildCopyright(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          left: -50,
          child: _blob(300, GlassTheme.primaryColor.withOpacity(0.15)),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: Offset(0, 0), end: Offset(50, 30), duration: 10.seconds),
        Positioned(
          bottom: -50,
          right: -50,
          child: _blob(350, Colors.purple.withOpacity(0.12)),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).move(begin: Offset(0, 0), end: Offset(-40, -50), duration: 12.seconds),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GlassTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(LucideIcons.graduationCap, size: 48, color: GlassTheme.primaryColor),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        SizedBox(height: 20),
        Text(
          'PrepGenZ',
          style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1),
        ).animate().fadeIn(delay: 200.ms),
        Text(
          _isLogin ? 'Welcome back' : 'Join the elite community',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ).animate(key: ValueKey(_isLogin)).fadeIn(duration: 400.ms),
      ],
    );
  }

  Widget _buildAuthCard() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(30),
      child: Column(
        children: [
          _buildRoleSelector(),
          SizedBox(height: 30),
          if (_errorMessage != null)
            _buildErrorBox(),
          if (!_isLogin) ...[
            _buildInputField('Full Name', LucideIcons.user, _nameController, "Enter your full name"),
            if (_activeRole != 'student') ...[
              SizedBox(height: 20),
              _buildInputField('Staff Access Code', LucideIcons.shieldCheck, _staffCodeController, "Enter secret code", isPassword: true),
            ],
            SizedBox(height: 20),
          ],
          _buildInputField('Email', LucideIcons.mail, _emailController, "Enter your email"),
          SizedBox(height: 20),
          _buildInputField('Password', LucideIcons.lock, _passwordController, "••••••••", isPassword: true),
          if (!_isLogin) ...[
            SizedBox(height: 20),
            _buildInputField('Confirm Password', LucideIcons.shieldCheck, _confirmPasswordController, "••••••••", isPassword: true),
          ],
          SizedBox(height: 40),
          _buildSubmitButton(),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          _roleButton('Student', LucideIcons.graduationCap, 'student'),
          _roleButton('Teacher', LucideIcons.school, 'teacher'),
          _roleButton('Management', LucideIcons.shieldCheck, 'management'),
        ],
      ),
    );
  }

  Widget _roleButton(String label, IconData icon, String role) {
    bool isActive = _activeRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeRole = role),
        child: AnimatedContainer(
          duration: 300.ms,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? GlassTheme.primaryColor : Colors.white38, size: 20),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, IconData icon, TextEditingController controller, String hint, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: GlassTheme.primaryColor,
            enableInteractiveSelection: true,
            cursorWidth: 2,
            cursorRadius: Radius.circular(2),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.white30, size: 18),
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBox() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Text(_errorMessage!, style: TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: GlassTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 20,
          shadowColor: GlassTheme.primaryColor.withOpacity(0.4),
        ),
        child: _isLoading 
          ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_isLogin ? LucideIcons.logIn : LucideIcons.userPlus, size: 20),
                SizedBox(width: 12),
                Text(_isLogin ? 'Login' : 'Sign Up', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
      ),
    );
  }

  Widget _buildFooterActions() {
    return TextButton(
      onPressed: () => setState(() {
        _isLogin = !_isLogin;
        _errorMessage = null;
      }),
      child: Text(
        _isLogin ? "New here? Create account" : 'Already have an account? Login',
        style: TextStyle(color: Colors.white60, fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCopyright() {
    return Text(
      '© 2026 Muhammad Rihan. All rights reserved.',
      style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w600),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final name = _nameController.text.trim();
      final staffCode = _staffCodeController.text.trim();

      if (_isLogin) {
        await auth.signIn(email, password);
      } else {
        if (password != _confirmPasswordController.text.trim()) {
          throw Exception("Passwords do not match");
        }
        if (name.isEmpty) {
          throw Exception("Full name is required");
        }
        await auth.signUp(
          email, 
          password, 
          name, 
          _activeRole,
          staffCode: _activeRole != 'student' ? staffCode : null,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration successful! Please login.")),
        );
        setState(() => _isLogin = true);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (errorMessage.contains('invalid_credentials') || errorMessage.contains('Invalid login credentials')) {
        errorMessage = 'Invalid email or password';
      }
      setState(() => _errorMessage = errorMessage);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
