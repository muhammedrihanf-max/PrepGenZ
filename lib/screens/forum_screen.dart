import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';
import '../services/auth_provider.dart';
import '../models/forum.dart';

import '../services/forum_service.dart';
import '../components/math_text.dart';

class ForumScreen extends StatefulWidget {
  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final TextEditingController _postController = TextEditingController();
  final ForumService _forumService = ForumService();
  bool _isLoading = false;

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
                  Text('Community Forum', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Share thoughts and collaborate with peers', style: TextStyle(color: Colors.white70)),
                ],
              ),
              SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 30),
          _buildPostInput(),
          SizedBox(height: 20),
          _buildTrendingTopics(),
          SizedBox(height: 30),
          _buildGuidelines(),
          SizedBox(height: 30),
          _buildPostsList(),
        ],
      ),
    );
  }

  Widget _buildTrendingTopics() {
    final topics = ['#ExamTips', '#PhysicsStudy', '#TimeManagement', '#Motivation'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: topics.map((t) => Container(
          margin: EdgeInsets.only(right: 12),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: GlassTheme.glassDecoration(opacity: 0.1, borderRadius: 20),
          child: Text(t, style: TextStyle(color: GlassTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
        )).toList(),
      ),
    );
  }

  Widget _buildGuidelines() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shieldCheck, color: Colors.greenAccent, size: 20),
              SizedBox(width: 10),
              Text('Community Guidelines', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 12),
          _guidelineItem('Be respectful and kind to others'),
          _guidelineItem('No spam or irrelevant links'),
          _guidelineItem('Encourage and support your peers'),
          _guidelineItem('Use appropriate language at all times'),
        ],
      ),
    );
  }

  Widget _guidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(LucideIcons.chevronRight, color: Colors.white24, size: 14),
          SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.white70, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return StreamBuilder<List<ForumPost>>(
      stream: _forumService.subscribeToPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor));
        }
        final posts = snapshot.data ?? [];
        
        // Calculate dynamic stats
        int totalLikes = 0;
        for (var p in posts) totalLikes += p.likes.length;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildStats(posts.length, totalLikes),
              ],
            ),
            SizedBox(height: 20),
            if (posts.isEmpty)
              Center(child: Text('No posts yet. Start the conversation!', style: TextStyle(color: Colors.white38)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _buildPostCard(posts[index], index);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildStats(int postCount, int likeCount) {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _statItem(postCount.toString(), 'Posts'),
          Container(width: 1, height: 20, color: Colors.white24, margin: EdgeInsets.symmetric(horizontal: 12)),
          _statItem(likeCount.toString(), 'Likes'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildPostInput() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16, 
                backgroundColor: GlassTheme.primaryColor.withOpacity(0.2),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final name = auth.user?.userMetadata?['name'] ?? 'User';
                    final seed = auth.user?.userMetadata?['avatar_seed'] ?? name;
                    return ClipOval(
                      child: Image.network(
                        'https://api.dicebear.com/7.x/avataaars/png?seed=$seed',
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          name[0].toUpperCase(),
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    );
                  }
                ),
              ),
              SizedBox(width: 12),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  'Posting as ${auth.role.toUpperCase()}', 
                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          TextField(
            controller: _postController,
            maxLines: 3,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "What's on your mind?",
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final auth = Provider.of<AuthProvider>(context, listen: false);
                  if (_postController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please write something first! ✍️')));
                    return;
                  }
                  
                  if (auth.user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('You must be logged in to post.')));
                    return;
                  }

                  setState(() => _isLoading = true);
                  
                  try {
                    final role = auth.role;
                    final name = auth.user!.userMetadata?['name'] ?? 'User';
                    
                    await _forumService.addPost(
                      _postController.text.trim(), 
                      auth.user!.id, 
                      name, 
                      role
                    );
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(backgroundColor: Colors.green, content: Text('Post published to community! ✨')),
                      );
                      _postController.clear();
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(backgroundColor: Colors.redAccent, content: Text('Failed to post: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                icon: Icon(LucideIcons.plus, size: 18),
                label: Text('Post to Forum'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlassTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildPostCard(ForumPost post, int index) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    final isLiked = userId != null && post.likes.contains(userId);

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: GlassTheme.glassWrapper(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigo.withOpacity(0.2),
                  child: ClipOval(
                    child: Image.network(
                      post.authorPhoto ?? 'https://api.dicebear.com/7.x/avataaars/png?seed=${post.authorName}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Text(
                        post.authorName[0].toUpperCase(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('${post.authorRole ?? "Student"} • ${post.timestamp.hour}:${post.timestamp.minute}', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
                Spacer(),
                PopupMenuButton(
                  icon: Icon(LucideIcons.moreVertical, color: Colors.white24, size: 16),
                  itemBuilder: (context) => [
                    if (userId == post.authorId || auth.role == 'teacher' || auth.role == 'management')
                      PopupMenuItem(
                        child: Text('Delete Post', style: TextStyle(color: Colors.redAccent)),
                        onTap: () => _forumService.deletePost(post.id),
                      ),
                    if ((auth.role == 'teacher' || auth.role == 'management') && post.moderationStatus == 'hidden')
                      PopupMenuItem(
                        child: Text('Approve Post', style: TextStyle(color: Colors.greenAccent)),
                        onTap: () => _forumService.approvePost(post.id),
                      ),
                    if (auth.role == 'student' && userId != post.authorId)
                      PopupMenuItem(
                        child: Text('Report Abuse', style: TextStyle(color: Colors.orangeAccent)),
                        onTap: () {
                          _forumService.flagPost(post.id, userId!);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Post flagged to moderators.')));
                        },
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            if (post.moderationStatus == 'hidden' && auth.role == 'student')
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    Icon(LucideIcons.shieldAlert, color: Colors.orangeAccent, size: 16),
                    SizedBox(width: 8),
                    Text('This content is under moderator review.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12)),
                  ],
                ),
              )
            else ...[
              if (post.moderationStatus == 'hidden')
                Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                  child: Text('FLAGGED FOR REVIEW', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              MathText(
                post.content,
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              ),
            ],
            SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () => userId != null ? _forumService.likePost(post.id, userId) : null,
                  child: _postAction(LucideIcons.heart, post.likes.length.toString(), color: isLiked ? Colors.pink : Colors.white60),
                ),
                SizedBox(width: 20),
                _postAction(LucideIcons.messageSquare, '${post.replies.length} Replies'),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX();
  }

  Widget _postAction(IconData icon, String label, {Color color = Colors.white60}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 13)),
      ],
    );
  }
}
