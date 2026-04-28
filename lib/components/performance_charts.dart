import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/glass_theme.dart';

class PerformanceCharts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatCards(),
        SizedBox(height: 30),
        _buildAreaChart(),
        SizedBox(height: 30),
        _buildRadarChart(),
      ],
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _statCard('Avg. Accuracy', '84%', LucideIcons.activity, Colors.blue),
        _statCard('Total Attempts', '12', LucideIcons.target, Colors.purple),
        _statCard('Global Rank', '#42', LucideIcons.award, Colors.orange),
        _statCard('Mastery', 'Expert', LucideIcons.brain, Colors.teal),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          Spacer(),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAreaChart() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Container(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 3),
                  FlSpot(2.6, 2),
                  FlSpot(4.9, 5),
                  FlSpot(6.8, 3.1),
                  FlSpot(8, 4),
                  FlSpot(9.5, 3),
                  FlSpot(11, 4),
                ],
                isCurved: true,
                color: GlassTheme.primaryColor,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: GlassTheme.primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    return GlassTheme.glassWrapper(
      padding: EdgeInsets.all(20),
      child: Container(
        height: 250,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                fillColor: Colors.purple.withOpacity(0.2),
                borderColor: Colors.purple,
                entryRadius: 3,
                dataEntries: [
                  RadarEntry(value: 80),
                  RadarEntry(value: 90),
                  RadarEntry(value: 70),
                  RadarEntry(value: 85),
                  RadarEntry(value: 60),
                ],
              ),
            ],
            radarShape: RadarShape.circle,
            getTitle: (index, _) {
              switch (index) {
                case 0: return RadarChartTitle(text: 'Physics');
                case 1: return RadarChartTitle(text: 'Math');
                case 2: return RadarChartTitle(text: 'Bio');
                case 3: return RadarChartTitle(text: 'Chem');
                case 4: return RadarChartTitle(text: 'Eng');
                default: return RadarChartTitle(text: '');
              }
            },
            tickCount: 5,
            ticksTextStyle: TextStyle(color: Colors.white24, fontSize: 10),
            gridBorderData: BorderSide(color: Colors.white12),
          ),
        ),
      ),
    );
  }
}
