// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:frontend/services/api_service.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'dart:convert';

// class AnalyticsModule extends StatelessWidget {
//   final Future<Map<String, dynamic>> statsFuture;
//   final VoidCallback onRefresh;
//   final double width;
//   final Color msuMaroon;
//   final Color colorEmerald;
//   final Color colorSlateText;
//   final Color surfaceColor;

//   const AnalyticsModule({
//     super.key,
//     required this.statsFuture,
//     required this.onRefresh,
//     required this.width,
//     required this.msuMaroon,
//     required this.colorEmerald,
//     required this.colorSlateText,
//     required this.surfaceColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: statsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//         if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
//         final s = snapshot.data ?? {'High': 0, 'Moderate': 0, 'Low': 0};
        
//         return RefreshIndicator(
//           onRefresh: () async => onRefresh(),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Assessment Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
//                 const SizedBox(height: 20),
//                 GridView.count(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisCount: width < 600 ? 1 : (width < 1100 ? 2 : 3),
//                   crossAxisSpacing: 20,
//                   mainAxisSpacing: 20,
//                   childAspectRatio: 2.5,
//                   children: [
//                     _statCard("High Risk", s['High']?.toString() ?? "0", const Color(0xFFDC2626), Icons.analytics_outlined),
//                     _statCard("Moderate", s['Moderate']?.toString() ?? "0", const Color(0xFFD97706), Icons.insights_rounded),
//                     _statCard("Healthy", s['Low']?.toString() ?? "0", colorEmerald, Icons.verified_user_outlined),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
//                 const Text("Risk Trends (Monthly)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
//                 const SizedBox(height: 16),
//                 Container(
//                   height: 300,
//                   padding: const EdgeInsets.only(right: 24, top: 20, bottom: 10),
//                   decoration: BoxDecoration(
//                     color: surfaceColor, 
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.grey.withOpacity(0.1))
//                   ),
//                   child: _buildTrendChart(s),
//                 ),
//                 const SizedBox(height: 30),
//                 const Text("Recent Submissions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 FutureBuilder<List<dynamic>>(
//                   future: ApiService.getAssessmentLogs(), 
//                   builder: (context, logSnapshot) {
//                     if (!logSnapshot.hasData) return const CircularProgressIndicator();
//                     final logs = logSnapshot.data!;
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: logs.length,
//                       // Inside your ListView.builder's itemBuilder:
//                       itemBuilder: (context, index) {
//                         final log = logs[index];
                        
//                         // Safe Date Parsing
//                         String displayDate = "Unknown Date";
//                         if (log['date'] != null && log['date'] is String) {
//                           displayDate = log['date'].toString().split('T')[0]; 
//                         }

//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 8),
//                           child: ListTile(
//                             leading: CircleAvatar(
//                               backgroundColor: log['level'] == 'High' ? Colors.red : Colors.green,
//                               child: Text(
//                                 (log['score'] ?? 0).toString(), 
//                                 style: const TextStyle(color: Colors.white, fontSize: 12)
//                               ),
//                             ),
//                             title: Text("Anonymous ${log['type'] ?? 'User'}"),
//                             subtitle: Text("Submitted: $displayDate"), // Used the safe date here
//                             trailing: const Icon(Icons.chevron_right),
//                             onTap: () => _showAssessmentDetail(context, log),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // --- NEW FUNCTION ADDED HERE ---
//   void _showAssessmentDetail(BuildContext context, dynamic log) async {
//     // 1. Load the questionnaire decoder
//     final String response = await rootBundle.loadString('assets/questions.json');
//     final data = json.decode(response);
//     final List<dynamic> sections = data['sections'];

//     // 2. Parse the raw_answers from string back to a List of Lists
//     // Note: Neo4j might return this as a String or a List depending on driver version.
//     List<dynamic> rawAnswers;
//     try {
//       rawAnswers = log['answers'] is String 
//           ? json.decode(log['answers']) 
//           : log['answers'];
//     } catch (e) {
//       rawAnswers = [];
//     }

//     if (!context.mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Assessment Review", style: TextStyle(fontWeight: FontWeight.bold)),
//             Text("Type: ${log['type']} | Score: ${log['score']}", 
//                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 500, // Fixed height for the scrollable area
//           child: rawAnswers.isEmpty 
//             ? const Center(child: Text("Detailed answers unavailable for this record."))
//             : ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: sections.length,
//                 itemBuilder: (context, sIndex) {
//                   final section = sections[sIndex];
//                   final sectionAnswers = rawAnswers[sIndex] as List<dynamic>;

//                   return ExpansionTile(
//                     title: Text(section['title'], 
//                                 style: TextStyle(color: msuMaroon, fontWeight: FontWeight.bold, fontSize: 14)),
//                     children: List.generate(section['questions'].length, (qIndex) {
//                       final questionText = section['questions'][qIndex];
//                       final answerValue = sectionAnswers[qIndex];
                      
//                       // Find the text description for the numerical value (e.g., 1 -> "Not at all")
//                       final option = (section['options'] as List).firstWhere(
//                         (opt) => opt['value'] == answerValue,
//                         orElse: () => {'text': 'Unknown'},
//                       );

//                       return ListTile(
//                         title: Text(questionText, style: const TextStyle(fontSize: 13)),
//                         subtitle: Text(option['text'], 
//                                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                       );
//                     }),
//                   );
//                 },
//               ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), 
//             child: const Text("Close", style: TextStyle(color: Colors.grey))
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statCard(String label, String value, Color color, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.1)),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: color, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
//                 Text(label, style: TextStyle(color: colorSlateText, fontWeight: FontWeight.w600, fontSize: 12)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildTrendChart(Map<String, dynamic> s) {
//     List<dynamic> high = s['trend_high'] ?? [];
//     List<dynamic> mod = s['trend_mod'] ?? [];
//     List<dynamic> low = s['trend_low'] ?? [];

//     return LineChart(
//       LineChartData(
//         gridData: const FlGridData(show: true, drawVerticalLine: false),
//         titlesData: FlTitlesData(
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//                 int monthIndex = (DateTime.now().month - 6 + value.toInt()) % 12;
//                 if (monthIndex < 0) monthIndex += 12;
//                 return Text(months[monthIndex], style: TextStyle(color: colorSlateText, fontSize: 10));
//               },
//             ),
//           ),
//         ),
//         lineBarsData: [
//           _lineData(high, msuMaroon),
//           _lineData(mod, Colors.orange),
//           _lineData(low, colorEmerald),
//         ],
//       ),
//     );
//   }

//   LineChartBarData _lineData(List<dynamic> data, Color color) {
//     return LineChartBarData(
//       spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
//       isCurved: true,
//       color: color,
//       barWidth: 3,
//       dotData: const FlDotData(show: true),
//       belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart'; // Add this for formatting
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import 'package:frontend/services/api_service.dart';

// class AnalyticsModule extends StatelessWidget {
//   final Future<Map<String, dynamic>> statsFuture;
//   final VoidCallback onRefresh;
//   final double width;
//   final Color msuMaroon;
//   final Color colorEmerald;
//   final Color colorSlateText;
//   final Color surfaceColor;

//   const AnalyticsModule({
//     super.key,
//     required this.statsFuture,
//     required this.onRefresh,
//     required this.width,
//     required this.msuMaroon,
//     required this.colorEmerald,
//     required this.colorSlateText,
//     required this.surfaceColor,
//   });

//   // --- START: TIME PARSING LOGIC (Ported from AppointmentModule) ---
//   DateTime _parseBackendTimestamp(dynamic timestamp) {
//     if (timestamp == null) return DateTime(2000);
//     try {
//       if (timestamp is Map) {
//         final datePart = timestamp['_DateTime__date'] ?? {};
//         final timePart = timestamp['_DateTime__time'] ?? {};
//         return DateTime.utc(
//           datePart['_Date__year'] ?? 2000,
//           datePart['_Date__month'] ?? 1,
//           datePart['_Date__day'] ?? 1,
//           timePart['_Time__hour'] ?? 0,
//           timePart['_Time__minute'] ?? 0,
//           timePart['_Time__second'] ?? 0,
//         ).toLocal();
//       }
//       String tsString = timestamp.toString();
//       if (tsString.contains(' ') && !tsString.contains('T')) {
//         tsString = tsString.replaceFirst(' ', 'T');
//       }
//       return DateTime.tryParse(tsString)?.toUtc().toLocal() ?? DateTime(2000);
//     } catch (e) {
//       return DateTime(2000);
//     }
//   }

//   Map<String, dynamic> _getTimeInfo(dynamic timestamp) {
//     if (timestamp == null || timestamp.toString() == "null") {
//       return {"text": "Unknown Date", "isNew": false};
//     }

//     DateTime dt = _parseBackendTimestamp(timestamp);
//     if (dt.year == 2000) return {"text": "Invalid", "isNew": false};

//     DateTime now = DateTime.now();
//     Duration diff = now.difference(dt);
    
//     // Flag as new if submitted in the last hour
//     bool isNew = diff.inHours < 1 && !diff.isNegative;

//     String text;
//     if (diff.inSeconds < 60 && !diff.isNegative) {
//       text = "Just now";
//     } else if (diff.inMinutes < 60 && !diff.isNegative) {
//       text = "${diff.inMinutes}m ago";
//     } else if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
//       text = "Today, ${DateFormat('jm').format(dt)}";
//     } else if (dt.day == now.subtract(const Duration(days: 1)).day) {
//       text = "Yesterday";
//     } else {
//       text = DateFormat('MMM d, y').format(dt);
//     }
    
//     return {"text": text, "isNew": isNew};
//   }
//   // --- END: TIME PARSING LOGIC ---

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: statsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//         if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
//         final s = snapshot.data ?? {'High': 0, 'Moderate': 0, 'Low': 0};
        
//         return RefreshIndicator(
//           onRefresh: () async => onRefresh(),
//           child: SingleChildScrollView(
//             physics: const AlwaysScrollableScrollPhysics(),
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text("Assessment Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
//                   const SizedBox(height: 20),
//                   GridView.count(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     crossAxisCount: width < 600 ? 1 : (width < 1100 ? 2 : 3),
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 20,
//                     childAspectRatio: 2.5,
//                     children: [
//                       _statCard("High Risk", s['High']?.toString() ?? "0", const Color(0xFFDC2626), Icons.analytics_outlined),
//                       _statCard("Moderate", s['Moderate']?.toString() ?? "0", const Color(0xFFD97706), Icons.insights_rounded),
//                       _statCard("Healthy", s['Low']?.toString() ?? "0", colorEmerald, Icons.verified_user_outlined),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
//                   const Text("Risk Trends (Monthly)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
//                   const SizedBox(height: 16),
//                   Container(
//                     height: 300,
//                     padding: const EdgeInsets.only(right: 24, top: 20, bottom: 10),
//                     decoration: BoxDecoration(
//                       color: surfaceColor, 
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.grey.withOpacity(0.1))
//                     ),
//                     child: _buildTrendChart(s),
//                   ),
                
//                 const SizedBox(height: 30),
//                 const Text("Recent Submissions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 FutureBuilder<List<dynamic>>(
//                   future: ApiService.getAssessmentLogs(), 
//                   builder: (context, logSnapshot) {
//                     if (logSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//                     if (!logSnapshot.hasData || logSnapshot.data!.isEmpty) return const Text("No recent assessments found.");
                    
//                     final logs = logSnapshot.data!;
//                     return ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: logs.length,
//                       // Inside AnalyticsModule -> build -> Recent Submissions ListView.builder
//                       itemBuilder: (context, index) {
//                         final log = logs[index];
//                         var timeInfo = _getTimeInfo(log['date']);
//                         bool isLinked = log['is_linked'] ?? false;

//                         return Card(
//                           margin: const EdgeInsets.only(bottom: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             // Highlight linked logs with a subtle border
//                             side: isLinked ? BorderSide(color: colorEmerald.withOpacity(0.5), width: 1) : BorderSide.none,
//                           ),
//                           child: ListTile(
//                             leading: CircleAvatar(
//                               backgroundColor: log['level'] == 'High' ? Colors.red : (log['level'] == 'Moderate' ? Colors.orange : Colors.green),
//                               child: Text(
//                                 (log['score'] ?? 0).toString(), 
//                                 style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
//                               ),
//                             ),
//                             title: Row(
//                               children: [
//                                 // Use the display_name from the backend (prioritizes appointment name)
//                                 Text(log['display_name'] ?? "Anonymous User", style: const TextStyle(fontWeight: FontWeight.bold)),
//                                 if (isLinked) ...[
//                                   const SizedBox(width: 8),
//                                   const Icon(Icons.link, size: 16, color: Colors.green),
//                                 ]
//                               ],
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Submitted: ${timeInfo['text']}"),
//                                 if (isLinked) 
//                                   Text("Linked to: #${log['linked_ref']}", 
//                                       style: TextStyle(color: colorEmerald, fontSize: 10, fontWeight: FontWeight.bold)),
//                               ],
//                             ),
//                             trailing: const Icon(Icons.chevron_right),
//                             onTap: () => _showAssessmentDetail(context, log),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// // --- NEW FUNCTION ADDED HERE ---
//   void _showAssessmentDetail(BuildContext context, dynamic log) async {
//     // 1. Load the questionnaire decoder
//     final String response = await rootBundle.loadString('assets/questions.json');
//     final data = json.decode(response);
//     final List<dynamic> sections = data['sections'];

//     // 2. Parse the raw_answers from string back to a List of Lists
//     // Note: Neo4j might return this as a String or a List depending on driver version.
//     List<dynamic> rawAnswers;
//     try {
//       rawAnswers = log['answers'] is String 
//           ? json.decode(log['answers']) 
//           : log['answers'];
//     } catch (e) {
//       rawAnswers = [];
//     }

//     if (!context.mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Assessment Review", style: TextStyle(fontWeight: FontWeight.bold)),
//             Text("Type: ${log['type']} | Score: ${log['score']}", 
//                 style: const TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           height: 500, // Fixed height for the scrollable area
//           child: rawAnswers.isEmpty 
//             ? const Center(child: Text("Detailed answers unavailable for this record."))
//             : ListView.builder(
//                 shrinkWrap: true,
//                 itemCount: sections.length,
//                 itemBuilder: (context, sIndex) {
//                   final section = sections[sIndex];
//                   final sectionAnswers = rawAnswers[sIndex] as List<dynamic>;

//                   return ExpansionTile(
//                     title: Text(section['title'], 
//                                 style: TextStyle(color: msuMaroon, fontWeight: FontWeight.bold, fontSize: 14)),
//                     children: List.generate(section['questions'].length, (qIndex) {
//                       final questionText = section['questions'][qIndex];
//                       final answerValue = sectionAnswers[qIndex];
                      
//                       // Find the text description for the numerical value (e.g., 1 -> "Not at all")
//                       final option = (section['options'] as List).firstWhere(
//                         (opt) => opt['value'] == answerValue,
//                         orElse: () => {'text': 'Unknown'},
//                       );

//                       return ListTile(
//                         title: Text(questionText, style: const TextStyle(fontSize: 13)),
//                         subtitle: Text(option['text'], 
//                                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                       );
//                     }),
//                   );
//                 },
//               ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), 
//             child: const Text("Close", style: TextStyle(color: Colors.grey))
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statCard(String label, String value, Color color, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: surfaceColor,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: color.withOpacity(0.1)),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: color, size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
//                 Text(label, style: TextStyle(color: colorSlateText, fontWeight: FontWeight.w600, fontSize: 12)),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildTrendChart(Map<String, dynamic> s) {
//     List<dynamic> high = s['trend_high'] ?? [];
//     List<dynamic> mod = s['trend_mod'] ?? [];
//     List<dynamic> low = s['trend_low'] ?? [];

//     return LineChart(
//       LineChartData(
//         gridData: const FlGridData(show: true, drawVerticalLine: false),
//         titlesData: FlTitlesData(
//           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               getTitlesWidget: (value, meta) {
//                 const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
//                 int monthIndex = (DateTime.now().month - 6 + value.toInt()) % 12;
//                 if (monthIndex < 0) monthIndex += 12;
//                 return Text(months[monthIndex], style: TextStyle(color: colorSlateText, fontSize: 10));
//               },
//             ),
//           ),
//         ),
//         lineBarsData: [
//           _lineData(high, msuMaroon),
//           _lineData(mod, Colors.orange),
//           _lineData(low, colorEmerald),
//         ],
//       ),
//     );
//   }

//   LineChartBarData _lineData(List<dynamic> data, Color color) {
//     return LineChartBarData(
//       spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
//       isCurved: true,
//       color: color,
//       barWidth: 3,
//       dotData: const FlDotData(show: true),
//       belowBarData: BarAreaData(show: true, color: color.withOpacity(0.05)),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:frontend/services/api_service.dart';

class AnalyticsModule extends StatefulWidget {
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
  State<AnalyticsModule> createState() => _AnalyticsModuleState();
}

class _AnalyticsModuleState extends State<AnalyticsModule> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- TIME PARSING LOGIC ---
  DateTime _parseBackendTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime(2000);
    try {
      if (timestamp is Map) {
        final datePart = timestamp['_DateTime__date'] ?? {};
        final timePart = timestamp['_DateTime__time'] ?? {};
        return DateTime.utc(
          datePart['_Date__year'] ?? 2000,
          datePart['_Date__month'] ?? 1,
          datePart['_Date__day'] ?? 1,
          timePart['_Time__hour'] ?? 0,
          timePart['_Time__minute'] ?? 0,
          timePart['_Time__second'] ?? 0,
        ).toLocal();
      }
      String tsString = timestamp.toString();
      if (tsString.contains(' ') && !tsString.contains('T')) {
        tsString = tsString.replaceFirst(' ', 'T');
      }
      return DateTime.tryParse(tsString)?.toUtc().toLocal() ?? DateTime(2000);
    } catch (e) {
      return DateTime(2000);
    }
  }

  Map<String, dynamic> _getTimeInfo(dynamic timestamp) {
    if (timestamp == null || timestamp.toString() == "null") {
      return {"text": "Unknown Date", "isNew": false};
    }
    DateTime dt = _parseBackendTimestamp(timestamp);
    DateTime now = DateTime.now();
    Duration diff = now.difference(dt);
    bool isNew = diff.inHours < 1 && !diff.isNegative;
    return {
      "text": DateFormat('MMM d, h:mm a').format(dt),
      "isNew": isNew
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: widget.statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        
        final s = snapshot.data ?? {'High': 0, 'Moderate': 0, 'Low': 0};
        
        return RefreshIndicator(
          onRefresh: () async => widget.onRefresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Allows the column to wrap content
              children: [
                // 1. STAT CARDS
                const Text("Assessment Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 20),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: widget.width < 800 ? 1 : 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 2.5,
                  children: [
                    _statCard("High Risk", s['High']?.toString() ?? "0", const Color(0xFFDC2626), Icons.analytics_outlined),
                    _statCard("Moderate", s['Moderate']?.toString() ?? "0", const Color(0xFFD97706), Icons.insights_rounded),
                    _statCard("Healthy", s['Low']?.toString() ?? "0", widget.colorEmerald, Icons.verified_user_outlined),
                  ],
                ),
                
                const SizedBox(height: 32),

                // 2. TAB BAR
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: widget.msuMaroon,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: "All Submissions"),
                      Tab(text: "Identified"),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. RESPONSIVE LOG LIST
                // We use AnimatedBuilder to react to tab changes without a fixed-height SizedBox
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, child) {
                    return _buildLogList(
                      filterLinked: _tabController.index == 1,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogList({required bool filterLinked}) {
    return FutureBuilder<List<dynamic>>(
      future: ApiService.getAssessmentLogs(), 
      builder: (context, logSnapshot) {
        if (logSnapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (!logSnapshot.hasData || logSnapshot.data!.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No assessments found.")));
        }
        
        var logs = logSnapshot.data!;
        if (filterLinked) {
          logs = logs.where((l) => l['is_linked'] == true).toList();
        }

        return ListView.builder(
          shrinkWrap: true, // Let the list take only the space it needs
          physics: const NeverScrollableScrollPhysics(), // Let the main page handle scrolling
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            var timeInfo = _getTimeInfo(log['date']);
            bool isLinked = log['is_linked'] ?? false;
            final Color riskColor = log['level'] == 'High' ? Colors.red : (log['level'] == 'Moderate' ? Colors.orange : widget.colorEmerald);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: isLinked ? BorderSide(color: widget.colorEmerald.withOpacity(0.5), width: 1) : BorderSide.none,
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: riskColor,
                  child: Text(log['score'].toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                title: Row(
                  children: [
                    Text(log['display_name'] ?? "Anonymous User", style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (isLinked) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.link, size: 16, color: Colors.green),
                    ]
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Type: ${log['type'] ?? 'User'} • ${timeInfo['text']}", style: const TextStyle(fontSize: 12)),
                    if (isLinked) 
                      Text("Linked to: #${log['linked_ref']}", 
                          style: TextStyle(color: widget.colorEmerald, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAssessmentDetail(context, log),
              ),
            );
          },
        );
      },
    );
  }

  void _showAssessmentDetail(BuildContext context, dynamic log) async {
    final String response = await rootBundle.loadString('assets/questions.json');
    final data = json.decode(response);
    final List<dynamic> sections = data['sections'];

    List<dynamic> rawAnswers;
    try {
      rawAnswers = log['answers'] is String ? json.decode(log['answers']) : log['answers'];
    } catch (e) {
      rawAnswers = [];
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("${log['display_name']}'s Review"),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, sIndex) {
              final section = sections[sIndex];
              final sectionAnswers = rawAnswers[sIndex] as List<dynamic>;

              return ExpansionTile(
                title: Text(section['title'], style: TextStyle(color: widget.msuMaroon, fontWeight: FontWeight.bold, fontSize: 14)),
                children: List.generate(section['questions'].length, (qIndex) {
                  final option = (section['options'] as List).firstWhere(
                    (opt) => opt['value'] == sectionAnswers[qIndex],
                    orElse: () => {'text': 'Unknown'},
                  );

                  return ListTile(
                    title: Text(section['questions'][qIndex], style: const TextStyle(fontSize: 13)),
                    subtitle: Text(option['text'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  );
                }),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(color: widget.colorSlateText, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}