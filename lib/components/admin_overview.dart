import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';
import '../services/exam_service.dart';
import '../screens/exam_editor_screen.dart';

import 'package:provider/provider.dart';
import '../services/support_service.dart';
import '../services/auth_provider.dart';

class AdminOverview extends StatefulWidget {
  final Function(int)? onTabChange;
  AdminOverview({this.onTabChange});

  @override
  _AdminOverviewState createState() => _AdminOverviewState();
}

class _AdminOverviewState extends State<AdminOverview> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final examService = ExamService();
    try {
      final stats = await examService.getGlobalStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 30),
          _buildStatsGrid(),
          SizedBox(height: 30),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Admin',
                    style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Here's what's happening with your exams today.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(LucideIcons.megaphone, color: GlassTheme.primaryColor),
              onPressed: () => _showBroadcastDialog(),
              tooltip: 'Send Broadcast',
            ),
          ],
        ),
        SizedBox(height: 30),
        _buildQuickActions(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _actionButton(LucideIcons.plusCircle, 'New Exam', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ExamEditorScreen()));
            })),
            SizedBox(width: 12),
            Expanded(child: _actionButton(LucideIcons.users, 'Manage Users', () => widget.onTabChange?.call(3))),
            SizedBox(width: 12),
            Expanded(child: _actionButton(LucideIcons.clipboardList, 'Reports', () => widget.onTabChange?.call(6))),
          ],
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: GlassTheme.glassWrapper(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: GlassTheme.primaryColor, size: 24),
            SizedBox(height: 8),
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      {'label': 'Total Exams', 'value': _stats?['examCount']?.toString() ?? '0', 'icon': LucideIcons.fileText, 'color': Colors.purple},
      {'label': 'Total Students', 'value': _stats?['studentCount']?.toString() ?? '0', 'icon': LucideIcons.users, 'color': Colors.blue},
      {'label': 'Avg. Score', 'value': _stats?['avgScore'] ?? '0%', 'icon': LucideIcons.target, 'color': Colors.pink},
      {'label': 'Active Attempts', 'value': _stats?['activeAttempts']?.toString() ?? '0', 'icon': LucideIcons.zap, 'color': Colors.orange},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return GlassTheme.glassWrapper(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
              ),
              Spacer(),
              Text(stat['value'] as String, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text(stat['label'] as String, style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: ExamService().getRecentActivity(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) return Center(child: Text('No recent activity recorded.', style: TextStyle(color: Colors.white24)));
            
            return GlassTheme.glassWrapper(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (_, __) => Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final act = activities[index];
                  final profile = act['profiles'] as Map<String, dynamic>?;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: Icon(LucideIcons.graduationCap, color: GlassTheme.primaryColor, size: 16),
                    ),
                    title: Text('${profile?['name'] ?? 'Student'} completed ${act['exam_id']}', style: TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text('Score: ${act['score']}% • ${act['timestamp'].toString().split('T')[0]}', style: TextStyle(color: Colors.white54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _showBroadcastDialog() {
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
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      bool isSending = false;
                      return ElevatedButton(
                        onPressed: isSending ? null : () async {
                          if (_controller.text.trim().isEmpty) return;
                          
                          setDialogState(() => isSending = true);
                          try {
                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            final name = auth.user?.userMetadata?['name'] ?? 'Admin';
                            
                            await SupportService().sendBroadcast(
                              _controller.text.trim(), 
                              name, 
                              fromPhoto: auth.user?.userMetadata?['photo_url'] ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=$name'
                            );
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text('Broadcast sent successfully! 📢')));
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.redAccent, content: Text('Failed to send: ${e.toString()}')));
                            }
                          } finally {
                            if (context.mounted) setDialogState(() => isSending = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: GlassTheme.primaryColor),
                        child: isSending ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Send Now'),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
