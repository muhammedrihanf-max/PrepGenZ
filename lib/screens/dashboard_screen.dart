import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';
import '../services/auth_provider.dart';
import './forum_screen.dart';
import '../components/performance_charts.dart';
import './exam_screen.dart';
import './leaderboard_screen.dart';
import '../components/admin_overview.dart';
import './manage_exams_screen.dart';
import './student_management_screen.dart';
import './student_inquiries_screen.dart';
import './teacher_management_screen.dart';
import './staff_management_screen.dart';
import '../services/exam_service.dart';
import '../services/user_service.dart';
import '../services/offline_service.dart';
import '../models/exam.dart';
import '../services/support_service.dart';
import '../services/push_notification_service.dart';
import './profile_screen.dart';
import './reports_screen.dart';
import './notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeTabIndex = 0;
  final ExamService _examService = ExamService();
  List<ExamMetadata>? _exams;
  bool _isLoadingExams = true;

  @override
  void initState() {
    super.initState();
    _loadExams();
    OfflineService().startNetworkListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        PushNotificationService.listenToSupabase(auth.user!.id, auth.role);
      }
    });
  }


  Future<void> _loadExams() async {
    try {
      final exams = await _examService.getAllExams();
      if (mounted) {
        setState(() {
          _exams = exams;
          _isLoadingExams = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingExams = false);
    }
  }

  List<Map<String, dynamic>> _getTabs(String role) {
    if (role == 'student') {
      return [
        {'label': 'Practice Exams', 'icon': LucideIcons.graduationCap, 'id': 'practice'},
        {'label': 'Leaderboard', 'icon': LucideIcons.trophy, 'id': 'leaderboard'},
        {'label': 'Help & Support', 'icon': LucideIcons.helpCircle, 'id': 'help'},
        {'label': 'Insights', 'icon': LucideIcons.trendingUp, 'id': 'analytics'},
        {'label': 'Student Forum', 'icon': LucideIcons.users, 'id': 'forum'},
        {'label': 'Teacher Info', 'icon': LucideIcons.user, 'id': 'teacher'},
      ];
    } else {
      final tabs = [
        {'label': 'Overview', 'icon': LucideIcons.barChart3, 'id': 'overview'},
        {'label': 'Manage Exams', 'icon': LucideIcons.fileText, 'id': 'exams'},
        {'label': 'Leaderboard', 'icon': LucideIcons.trophy, 'id': 'leaderboard'},
        {'label': 'Students', 'icon': LucideIcons.graduationCap, 'id': 'students'},
        {'label': 'Student Inquiries', 'icon': LucideIcons.messageSquare, 'id': 'inquiries'},
        {'label': 'Community Forum', 'icon': LucideIcons.messageSquare, 'id': 'forum'},
        {'label': 'Reports', 'icon': LucideIcons.clipboardList, 'id': 'reports'},
      ];
      if (role == 'management') {
        tabs.add({'label': 'Teachers', 'icon': LucideIcons.briefcase, 'id': 'teachers'});
        tabs.add({'label': 'Staff Management', 'icon': LucideIcons.shieldAlert, 'id': 'staff'});
      }
      return tabs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final role = auth.role;
    final tabs = _getTabs(role);

    if (_activeTabIndex >= tabs.length) _activeTabIndex = 0;

    return Scaffold(
      backgroundColor: GlassTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GlassTheme.primaryColor.withOpacity(0.15),
              ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).moveY(begin: -20, end: 20, duration: 4.seconds),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(user, role),
                _buildTabNavigation(tabs),
                _buildBroadcastBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 400),
                    child: _buildMainContent(tabs),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic user, String role) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Image.asset('assets/favicon.png', width: 32, height: 32, errorBuilder: (_, __, ___) => Icon(LucideIcons.zap, color: GlassTheme.primaryColor)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PrepGenZ',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${role[0].toUpperCase()}${role.substring(1)} Portal',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.logOut, color: Colors.white54, size: 20),
            onPressed: () => auth.logout(),
            tooltip: 'Logout',
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(LucideIcons.bell, color: Colors.white70, size: 20),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsScreen())),
                tooltip: 'Notifications',
              ),
              StreamBuilder<int>(
                stream: SupportService().getUnreadNotificationsCount(user.id, role),
                builder: (context, snapshot) {
                  final count = snapshot.data ?? 0;
                  if (count == 0) return SizedBox.shrink();
                  return Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ],
          ),
          if (role == 'management' || role == 'teacher')
            IconButton(
              icon: Icon(LucideIcons.megaphone, color: GlassTheme.primaryColor, size: 20),
              onPressed: () => _showBroadcastDialog(context),
              tooltip: 'Send Global Broadcast',
            ).animate().shimmer(duration: 2.seconds),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())),
            child: CircleAvatar(
              backgroundColor: GlassTheme.primaryColor.withOpacity(0.2),
              backgroundImage: (user?.userMetadata?['photo_url'] != null && user?.userMetadata?['photo_url'].isNotEmpty) 
                ? NetworkImage(user!.userMetadata!['photo_url']) 
                : null,
              child: (user?.userMetadata?['photo_url'] == null || user?.userMetadata?['photo_url'].isEmpty)
                ? Text(user?.userMetadata?['name']?.substring(0, 1).toUpperCase() ?? user?.email?.substring(0, 1).toUpperCase() ?? 'S', style: TextStyle(color: Colors.white))
                : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(List<Map<String, dynamic>> tabs) {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final bool isActive = _activeTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _activeTabIndex = index),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: 12, bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: GlassTheme.glassDecoration(
                opacity: isActive ? 0.15 : 0.05,
                borderRadius: 30,
              ),
              child: Row(
                children: [
                   Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(tabs[index]['icon'], color: isActive ? Colors.white : Colors.white60, size: 18),
                      if (tabs[index]['id'] == 'inquiries')
                        StreamBuilder<int>(
                          stream: SupportService().getUnreadInquiriesCount(),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
                            if (count == 0) return SizedBox.shrink();
                            return Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                child: Text('$count', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  if (isActive) ...[
                    SizedBox(width: 8),
                    Text(tabs[index]['label'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(List<Map<String, dynamic>> tabs) {
    final String tabId = tabs[_activeTabIndex]['id'];

    // Global Screens
    if (tabId == 'forum') return ForumScreen();
    if (tabId == 'leaderboard') return LeaderboardScreen();

    // Student Only
    if (tabId == 'analytics') return SingleChildScrollView(padding: EdgeInsets.all(20), child: PerformanceCharts());

    // Admin/Teacher Only
    if (tabId == 'overview') return AdminOverview(onTabChange: (index) => setState(() => _activeTabIndex = index));
    if (tabId == 'exams') return ManageExamsScreen();
    if (tabId == 'students') return StudentManagementScreen();
    if (tabId == 'inquiries' || tabId == 'help') return StudentInquiriesScreen();
    if (tabId == 'teachers') return TeacherManagementScreen();
    if (tabId == 'staff') return StaffManagementScreen();
    if (tabId == 'teacher') return _buildTeacherList();
    if (tabId == 'reports') return ReportsScreen();

    return SingleChildScrollView(
      key: ValueKey(_activeTabIndex),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          SizedBox(height: 30),
          if (_isLoadingExams)
            Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor))
          else if (_exams == null || _exams!.isEmpty)
            Center(child: Text('No exams available yet.', style: TextStyle(color: Colors.white38)))
          else
            _buildExamGrid(_exams!),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back!',
          style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          'Ready to practice for your exams?',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildExamGrid(List<ExamMetadata> exams) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ExamScreen(year: exam.id)));
          },
          child: GlassTheme.glassWrapper(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(12)),
                  child: Text(exam.subject, style: TextStyle(color: Colors.white60, fontSize: 10)),
                ),
                Spacer(),
                Text(exam.title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.fileText, size: 12, color: GlassTheme.primaryColor),
                    SizedBox(width: 4),
                    Text('${exam.questionCount} Questions', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final questions = await ExamService().getQuestionsByYear(exam.id);
                          await OfflineService().cacheExam(exam.id, questions);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('${exam.title} is ready for Offline Mode! 📲')));
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text('Failed to download exam.')));
                        }
                      },
                      icon: Icon(LucideIcons.downloadCloud, size: 12),
                      label: Text('Save', style: TextStyle(fontSize: 10)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.1),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        minimumSize: Size(0, 26),
                      ),
                    ),
                    Spacer(),
                    Text('Start', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    Icon(LucideIcons.chevronRight, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildTeacherList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Our Faculty', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text('Expert instructors guiding your success', style: TextStyle(color: Colors.white70, fontSize: 14)),
          SizedBox(height: 20),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: UserService().getStaffProfiles(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
              final staff = snapshot.data ?? [];
              final teachers = staff.where((u) => u['role'] == 'teacher').toList();
              if (teachers.isEmpty) return Center(child: Text('No faculty members found.', style: TextStyle(color: Colors.white24)));
              return Column(
                children: teachers.map((t) => _buildTeacherCard(t['name'] ?? 'Instructor', (t['email'] ?? 'Faculty'))).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(String name, String role) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: GlassTheme.glassWrapper(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: Colors.white12, child: Text(name[0], style: TextStyle(color: Colors.white))),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(role, style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            Spacer(),
            Icon(LucideIcons.mail, color: Colors.white24, size: 18),
          ],
        ),
      ).animate().fadeIn().slideX(),
    );
  }

  Widget _buildReportsScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 100),
        Icon(LucideIcons.clipboardList, size: 80, color: Colors.white10),
        SizedBox(height: 20),
        Text('System Reports', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Text('Export your data to CSV format', style: TextStyle(color: Colors.white38)),
        SizedBox(height: 40),
        Center(
          child: ElevatedButton.icon(
            onPressed: () async {
              try {
                final csv = await _examService.exportResultsToCSV();
                // In a real app we'd use path_provider and share_plus to download.
                // For now, we'll show success and print to console (simulating generation).
                print(csv);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green.withOpacity(0.9),
                    content: Text('CSV Report generated and printed to console! 📊'),
                  )
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate report: $e')));
              }
            },
            icon: Icon(LucideIcons.download),
            label: Text('Export Student Results (CSV)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showBroadcastDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassTheme.glassWrapper(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Global Broadcast', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('This message will be visible to all students.', style: TextStyle(color: Colors.white54, fontSize: 12)),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 4,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_controller.text.trim().isEmpty) return;
                      final auth = Provider.of<AuthProvider>(context, listen: false);
                      final name = auth.user?.userMetadata?['name'] ?? 'Admin';
                      
                      await SupportService().sendBroadcast(_controller.text.trim(), name, fromPhoto: auth.user?.userMetadata?['photo_url']);
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Broadcast sent successfully! 📢')));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryColor),
                    child: Text('Send Now'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBroadcastBar() {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: SupportService().getLatestBroadcast(),
      builder: (context, snapshot) {
        final broadcast = snapshot.data;
        if (broadcast == null) return SizedBox.shrink();

        return Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: GlassTheme.glassWrapper(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderColor: GlassTheme.accentColor.withOpacity(0.5),
            opacity: 0.1,
            child: Row(
              children: [
                Icon(LucideIcons.megaphone, color: GlassTheme.accentColor, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ANNOUNCEMENT FROM ${broadcast['from_name']?.toString().toUpperCase() ?? 'ADMIN'}',
                        style: TextStyle(color: GlassTheme.accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        broadcast['message'] ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(LucideIcons.x, color: Colors.white24, size: 14),
                  onPressed: () {
                    // Logic to dismiss locally could be added here if needed.
                  },
                ),
              ],
            ),
          ).animate().slideY(begin: -0.2, end: 0).fadeIn().shimmer(color: GlassTheme.accentColor.withOpacity(0.1), duration: 3.seconds),
        );
      },
    );
  }
}
