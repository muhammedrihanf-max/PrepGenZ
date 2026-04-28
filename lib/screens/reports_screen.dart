import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/glass_theme.dart';
import '../services/exam_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _examService = ExamService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _allAttempts = [];
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _examService.getGlobalStats();
      final attempts = await _examService.getRecentActivity(); // We'll expand this for reports
      setState(() {
        _stats = stats;
        _allAttempts = attempts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleExport() async {
    setState(() => _isLoading = true);
    try {
      final csvContent = await _examService.exportResultsToCSV();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/prepgenz_report_${DateTime.now().millisecondsSinceEpoch}.csv');
      
      await file.writeAsString(csvContent);
      
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'PrepGenZ Exam Performance Report',
        subject: 'Exam Results CSV',
      );

      if (result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report shared successfully! 📊')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 30),
          _buildSummaryStats(),
          SizedBox(height: 30),
          _buildChartsSection(),
          SizedBox(height: 30),
          _buildAllAttemptsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'In-depth Analytics',
                style: TextStyle(color: Colors.white70, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleExport,
          icon: _isLoading 
            ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(LucideIcons.download, size: 16),
          label: Text('Export CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: GlassTheme.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(child: _statCard('Average Score', _stats['avgScore'] ?? '0%', LucideIcons.target, Colors.pinkAccent)),
        SizedBox(width: 16),
        Expanded(child: _statCard('Total Attempts', _stats['activeAttempts']?.toString() ?? '0', LucideIcons.zap, Colors.orangeAccent)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 16),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return Row(
      children: [
        Expanded(
          child: GlassTheme.glassWrapper(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Trend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 80, child: Padding(padding: EdgeInsets.only(top: 10), child: _buildLineChart())),
              ],
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: GlassTheme.glassWrapper(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Participation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 80, child: Center(child: Icon(LucideIcons.barChart3, color: Colors.white12, size: 40))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllAttemptsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Recent Attempts', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        _isLoading 
          ? Center(child: CircularProgressIndicator(color: GlassTheme.primaryColor))
          : GlassTheme.glassWrapper(
              padding: EdgeInsets.zero,
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _allAttempts.length,
                separatorBuilder: (_, __) => Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final attempt = _allAttempts[index];
                  final profile = attempt['profiles'] as Map<String, dynamic>?;
                  final score = attempt['score'] as int;
                  final status = score >= 50 ? 'Passed' : 'Failed';
                  final statusColor = score >= 50 ? Colors.greenAccent : Colors.redAccent;

                  return ListTile(
                    title: Text(profile?['name'] ?? 'Student', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(attempt['exam_id'] ?? 'Exam', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$score%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      ],
    );
  }

  Widget _buildLineChart() {
    if (_allAttempts.isEmpty) return Center(child: Text('Not enough data', style: TextStyle(color: Colors.white54)));
    
    // Sort chronologically if needed, but getRecentActivity already orders ASC
    final spots = _allAttempts.asMap().entries.map((e) {
      final index = e.key.toDouble();
      final score = (e.value['score'] as num).toDouble();
      return FlSpot(index, score);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble() > 0 ? (spots.length - 1).toDouble() : 1,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: GlassTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: GlassTheme.primaryColor.withOpacity(0.2)),
          ),
        ],
      ),
    );
  }
}
