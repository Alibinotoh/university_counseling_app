import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsModule extends StatelessWidget {
  final Future<Map<String, dynamic>> statsFuture;
  final VoidCallback onRefresh;
  final double width;
  final Color msuMaroon;
  final Color colorEmerald;
  final Color colorSlateText;
  final Color surfaceColor;

  const AnalyticsModule({
    super.key,
    required this.statsFuture,
    required this.onRefresh,
    required this.width,
    required this.msuMaroon,
    required this.colorEmerald,
    required this.colorSlateText,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
        final s = snapshot.data ?? {'High': 0, 'Moderate': 0, 'Low': 0};
        
        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Assessment Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: width < 600 ? 1 : (width < 1100 ? 2 : 3),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 2.5,
                  children: [
                    _statCard("High Risk", s['High']?.toString() ?? "0", const Color(0xFFDC2626), Icons.analytics_outlined),
                    _statCard("Moderate", s['Moderate']?.toString() ?? "0", const Color(0xFFD97706), Icons.insights_rounded),
                    _statCard("Healthy", s['Low']?.toString() ?? "0", colorEmerald, Icons.verified_user_outlined),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Risk Trends (Monthly)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.only(right: 24, top: 20, bottom: 10),
                  decoration: BoxDecoration(
                    color: surfaceColor, 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1))
                  ),
                  child: _buildTrendChart(s),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                Text(label, style: TextStyle(color: colorSlateText, fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTrendChart(Map<String, dynamic> s) {
    List<dynamic> high = s['trend_high'] ?? [];
    List<dynamic> mod = s['trend_mod'] ?? [];
    List<dynamic> low = s['trend_low'] ?? [];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                int monthIndex = (DateTime.now().month - 6 + value.toInt()) % 12;
                if (monthIndex < 0) monthIndex += 12;
                return Text(months[monthIndex], style: TextStyle(color: colorSlateText, fontSize: 10));
              },
            ),
          ),
        ),
        lineBarsData: [
          _lineData(high, msuMaroon),
          _lineData(mod, Colors.orange),
          _lineData(low, colorEmerald),
        ],
      ),
    );
  }

  LineChartBarData _lineData(List<dynamic> data, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
    );
  }
}