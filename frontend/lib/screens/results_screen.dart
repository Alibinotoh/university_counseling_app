// import 'package:flutter/material.dart';
// import '../models/assessment_result.dart';
// import 'assessment_screen.dart';
// import 'booking_screen.dart';

// class ResultsScreen extends StatelessWidget {
//   final AssessmentResult result;

//   const ResultsScreen({super.key, required this.result});

//   // BRAND COLOR
//   final Color msuMaroon = const Color(0xFF800020);

//   _ResultTheme _getTheme() {
//     if (result.level == "High") {
//       return _ResultTheme(
//         statusColor: Colors.redAccent, // Semantic color for danger
//         label: "HIGH STRESS LEVEL",
//         icon: Icons.warning_amber_rounded,
//         bg: const Color(0xFFFFF5F5),
//       );
//     } else if (result.level == "Moderate") {
//       return _ResultTheme(
//         statusColor: Colors.orange, // Semantic color for caution
//         label: "MODERATE STRESS",
//         icon: Icons.info_outline_rounded,
//         bg: const Color(0xFFFFF9F2),
//       );
//     } else {
//       return _ResultTheme(
//         statusColor: const Color(0xFF2E7D32), // Semantic color for healthy
//         label: "HEALTHY STANDING",
//         icon: Icons.check_circle_outline_rounded,
//         bg: const Color(0xFFF1F8E9),
//       );
//     }
//   }

//   String _getRecommendation() {
//     if (result.level == "High") {
//       return "Your scores indicate a high level of distress. We strongly encourage you to book an appointment with a counselor to talk things through.";
//     } else if (result.level == "Moderate") {
//       return "You seem to be experiencing some challenges. It might be helpful to schedule a session to discuss coping strategies.";
//     } else {
//       return "You are doing well! Continue practicing self-care. If you ever feel overwhelmed, our doors are always open.";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = _getTheme();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Assessment Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
              
//               // Animated Score Gauge
//               TweenAnimationBuilder<double>(
//                 tween: Tween<double>(begin: 0, end: result.finalScore),
//                 duration: const Duration(milliseconds: 1500),
//                 curve: Curves.easeOutQuart,
//                 builder: (context, value, child) {
//                   return Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         width: 180,
//                         height: 180,
//                         child: CircularProgressIndicator(
//                           value: value / 5, // Assuming max score is 5
//                           strokeWidth: 14,
//                           strokeCap: StrokeCap.round,
//                           backgroundColor: theme.statusColor.withOpacity(0.1),
//                           valueColor: AlwaysStoppedAnimation<Color>(theme.statusColor),
//                         ),
//                       ),
//                       Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             value.toStringAsFixed(1),
//                             style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: theme.statusColor),
//                           ),
//                           const Text("AVG SCORE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
//                         ],
//                       ),
//                     ],
//                   );
//                 },
//               ),

//               const SizedBox(height: 32),
              
//               // Status Badge
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: theme.statusColor,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(color: theme.statusColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(theme.icon, color: Colors.white, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       theme.label,
//                       style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Recommendation Card
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(24),
//                   border: Border.all(color: Colors.grey[200]!),
//                   boxShadow: [
//                     BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Text("Our Recommendation", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: msuMaroon)),
//                     const SizedBox(height: 12),
//                     Text(
//                       _getRecommendation(),
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7), height: 1.6),
//                     ),
//                   ],
//                 ),
//               ),

//               const Spacer(),

//               // Primary Action: Book Appointment (Always uses Maroon for Branding)
//               if (result.triggerWarning) ...[
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: msuMaroon,
//                     minimumSize: const Size(double.infinity, 60),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                     elevation: 0,
//                   ),
//                   onPressed: () {
//                     String reason = "Result: ${result.level} Stress (${result.finalScore.toStringAsFixed(1)} avg)";
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(initialReason: reason)));
//                   },
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.calendar_month, color: Colors.white),
//                       SizedBox(width: 10),
//                       Text("Schedule a Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//               ],

//               // Secondary Actions
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AssessmentScreen())),
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: const Size(0, 56),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                         side: BorderSide(color: msuMaroon.withOpacity(0.5)),
//                       ),
//                       child: Text("Retake Test", style: TextStyle(color: msuMaroon, fontWeight: FontWeight.bold)),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
//                       style: TextButton.styleFrom(minimumSize: const Size(0, 56)),
//                       child: const Text("Finish", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ResultTheme {
//   final Color statusColor; // Red, Orange, or Green based on severity
//   final String label;
//   final IconData icon;
//   final Color bg;
//   _ResultTheme({required this.statusColor, required this.label, required this.icon, required this.bg});
// }

import 'package:flutter/material.dart';
import '../models/assessment_result.dart';
import 'assessment_screen.dart';
import 'booking_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AssessmentResult result;
  final String userName; // Renamed from studentName

  const ResultsScreen({
    super.key, 
    required this.result, 
    this.userName = "Anonymous" 
  });

  final Color msuMaroon = const Color(0xFF800020);

  _ResultTheme _getTheme() {
    if (result.level == "High") {
      return _ResultTheme(
        statusColor: Colors.redAccent,
        label: "HIGH STRESS LEVEL",
        icon: Icons.warning_amber_rounded,
        bg: const Color(0xFFFFF5F5),
      );
    } else if (result.level == "Moderate") {
      return _ResultTheme(
        statusColor: Colors.orange,
        label: "MODERATE STRESS",
        icon: Icons.info_outline_rounded,
        bg: const Color(0xFFFFF9F2),
      );
    } else {
      return _ResultTheme(
        statusColor: const Color(0xFF2E7D32),
        label: "HEALTHY STANDING",
        icon: Icons.check_circle_outline_rounded,
        bg: const Color(0xFFF1F8E9),
      );
    }
  }

  String _getRecommendation() {
    // Generalized greeting
    String greeting = userName == "Anonymous" ? "Hello" : "Hello, $userName";
    
    if (result.level == "High") {
      return "$greeting. Your scores indicate a high level of distress. We strongly encourage you to book an appointment with a counselor to talk things through.";
    } else if (result.level == "Moderate") {
      return "$greeting. You seem to be experiencing some challenges. It might be helpful to schedule a session to discuss coping strategies.";
    } else {
      return "$greeting. You are doing well! Continue practicing self-care. If you ever feel overwhelmed, our doors are always open.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _getTheme();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          userName == "Anonymous" ? "Assessment Summary" : "$userName's Summary",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Score Gauge
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: result.finalScore),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutQuart,
                builder: (context, value, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: value / 5, 
                          strokeWidth: 14,
                          strokeCap: StrokeCap.round,
                          backgroundColor: theme.statusColor.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(theme.statusColor),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: theme.statusColor),
                          ),
                          const Text("AVG SCORE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                        ],
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 32),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.statusColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: theme.statusColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(theme.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      theme.label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recommendation Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    Text("Our Recommendation", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: msuMaroon)),
                    const SizedBox(height: 12),
                    Text(
                      _getRecommendation(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7), height: 1.6),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              if (result.triggerWarning) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: msuMaroon,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    String reason = "Result: ${result.level} Stress (${result.finalScore.toStringAsFixed(1)} avg)";
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingScreen(
                      initialReason: reason,
                      // Pre-fill name if they typed it in earlier
                      initialName: userName == "Anonymous" ? "" : userName, 
                    )));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Schedule a Session", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AssessmentScreen())),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: msuMaroon.withOpacity(0.5)),
                      ),
                      child: Text("Retake Test", style: TextStyle(color: msuMaroon, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                       style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: msuMaroon.withOpacity(0.5)),
                      ),
                      child: const Text("Finish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultTheme {
  final Color statusColor; 
  final String label;
  final IconData icon;
  final Color bg;
  _ResultTheme({required this.statusColor, required this.label, required this.icon, required this.bg});
}