import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/glass_theme.dart';

import '../services/exam_service.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _activeFilter = 'WEEKLY'; // Matches one of the build options
  final ExamService _examService = ExamService();
  List<Map<String, dynamic>>? _leaderboard;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    try {
      final data = await _examService.getLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = data;
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
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildFilters(),
            SizedBox(height: 40),
            if (_leaderboard == null || _leaderboard!.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Text('No results yet.', style: TextStyle(color: Colors.white38)),
              )
            else
              _buildPodium(_leaderboard!),
            Spacer(),
            _buildCurrentRank(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['DAILY', 'WEEKLY', 'MONTHLY'].map((filter) {
          bool isActive = _activeFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = filter),
            child: AnimatedContainer(
              duration: 300.ms,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isActive ? GlassTheme.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
                boxShadow: isActive ? [
                  BoxShadow(color: GlassTheme.primaryColor.withOpacity(0.3), blurRadius: 15, spreadRadius: 2)
                ] : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> leaderboard) {
    final first = leaderboard.isNotEmpty ? leaderboard[0] : null;
    final second = leaderboard.length > 1 ? leaderboard[1] : null;
    final third = leaderboard.length > 2 ? leaderboard[2] : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 2nd Place
          Expanded(
            child: second != null 
              ? _podiumCard(second['name'], '${second['score']} pts', '2', 'https://api.dicebear.com/7.x/avataaars/png?seed=${second['avatar_seed']}', false)
              : _podiumCard('---', '0 pts', '2', 'https://api.dicebear.com/7.x/avataaars/png?seed=empty2', false)
          ),
          SizedBox(width: 12),
          // 1st Place
          Expanded(
            child: first != null 
              ? _podiumCard(first['name'], '${first['score']} pts', '1', 'https://api.dicebear.com/7.x/avataaars/png?seed=${first['avatar_seed']}', true)
              : _podiumCard('---', '0 pts', '1', 'https://api.dicebear.com/7.x/avataaars/png?seed=empty1', true)
          ),
          SizedBox(width: 12),
          // 3rd Place
          Expanded(
            child: third != null 
              ? _podiumCard(third['name'], '${third['score']} pts', '3', 'https://api.dicebear.com/7.x/avataaars/png?seed=${third['avatar_seed']}', false)
              : _podiumCard('---', '0 pts', '3', 'https://api.dicebear.com/7.x/avataaars/png?seed=empty3', false)
          ),
        ],
      ),
    );
  }

  Widget _podiumCard(String name, String points, String rank, String avatarUrl, bool isFirst) {
    double scale = isFirst ? 1.1 : 0.95;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isFirst)
          Icon(LucideIcons.crown, color: Colors.orangeAccent, size: 30)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -5, duration: 1.seconds),
        SizedBox(height: 8),
        GlassTheme.glassWrapper(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isFirst ? Colors.orangeAccent.withOpacity(0.5) : GlassTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isFirst 
                              ? [Colors.orangeAccent, Colors.yellowAccent] 
                              : [GlassTheme.primaryColor, Colors.blueAccent],
                          ),
                        ),
                        child: CircleAvatar(
                          radius: isFirst ? 40 : 35,
                          backgroundColor: Colors.white10,
                          child: ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Center(
                                child: Text(
                                  name[0].toUpperCase(),
                                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFirst ? Colors.orangeAccent : Colors.grey[700],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black45, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        rank,
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  points,
                  style: TextStyle(color: GlassTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ).animate().scale(begin: Offset(scale, scale), end: Offset(scale, scale)).fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildCurrentRank() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR CURRENT RANK',
                style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              SizedBox(height: 8),
              Text(
                '#1',
                style: TextStyle(color: GlassTheme.primaryColor, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Spacer(),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.trendingUp, color: Colors.greenAccent, size: 24),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
