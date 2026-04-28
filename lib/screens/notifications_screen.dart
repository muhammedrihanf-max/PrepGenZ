import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';
import '../services/support_service.dart';
import '../services/auth_provider.dart';

class NotificationsScreen extends StatelessWidget {
  final SupportService _supportService = SupportService();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;
    final role = auth.role;

    if (user == null) return Scaffold(backgroundColor: GlassTheme.backgroundColor, body: Center(child: Text('Please login', style: TextStyle(color: Colors.white))));

    return Scaffold(
      backgroundColor: GlassTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: GlassTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, user.id, role),
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _supportService.getNotifications(user.id, role),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
                      }
                      
                      final notifications = snapshot.data ?? [];
                      if (notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.bellOff, size: 64, color: Colors.white10),
                              SizedBox(height: 16),
                              Text('No notifications yet', style: TextStyle(color: Colors.white24, fontSize: 16)),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return _buildNotificationCard(context, n);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userId, String role) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () => _supportService.markAllAsRead(userId, role),
            icon: Icon(LucideIcons.checkCheck, color: GlassTheme.primaryColor),
            tooltip: 'Mark All Read',
          ),
          IconButton(
            onPressed: () => _supportService.clearAllNotifications(userId, role),
            icon: Icon(LucideIcons.trash2, color: Colors.redAccent.withOpacity(0.7)),
            tooltip: 'Clear All',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification) {
    final bool isUnread = notification['read'] == false;
    final bool isBroadcast = notification['is_broadcast'] == true;
    final String type = isBroadcast ? 'ANNOUNCEMENT' : 'INQUIRY';
    final Color accentColor = isBroadcast ? GlassTheme.accentColor : GlassTheme.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(notification['id'].toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _supportService.deleteNotification(notification['id'].toString()),
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: Icon(LucideIcons.trash2, color: Colors.redAccent),
        ),
        child: GlassTheme.glassWrapper(
          padding: EdgeInsets.all(16),
          borderColor: isUnread ? accentColor.withOpacity(0.3) : Colors.white10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBroadcast ? LucideIcons.megaphone : LucideIcons.messageSquare,
                  color: accentColor,
                  size: 18,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          type,
                          style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification['from_name'] ?? 'System',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _formatTimestamp(notification['timestamp']),
                      style: TextStyle(color: Colors.white24, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (e) {
      return '';
    }
  }
}
