// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'screens/landing_page.dart';
// import 'screens/admin/admin_dashboard.dart'; // Import this to direct to dashboard

// // main.dart
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final prefs = await SharedPreferences.getInstance();
  
//   // Get the string
//   String? adminDataStr = prefs.getString('admin_data');
  
//   Map<String, dynamic>? savedAdmin;

//   // STRICT CHECK: Ensure it's not null, not empty, and not the literal string "null"
//   if (adminDataStr != null && adminDataStr.isNotEmpty && adminDataStr != "null") {
//     try {
//       savedAdmin = jsonDecode(adminDataStr);
//     } catch (e) {
//       debugPrint("Error decoding: $e");
//       savedAdmin = null;
//     }
//   }

//   runApp(GuidanceApp(initialAdmin: savedAdmin));
// }

// class GuidanceApp extends StatelessWidget {
//   final Map<String, dynamic>? initialAdmin;
  
//   const GuidanceApp({super.key, this.initialAdmin});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         primaryColor: const Color(0xFF800020), // Setting your Maroon theme globally
//       ),
//       // If initialAdmin has data, go to Dashboard; otherwise, LandingPage
//       home: initialAdmin != null 
//           ? AdminDashboard(adminData: initialAdmin!) 
//           : const LandingPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'session_gate.dart';

void main() {
  runApp(const GuidanceApp());
}

class GuidanceApp extends StatelessWidget {
  const GuidanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF800020),
      ),
      home: const SessionGate(), // ✅ THIS IS THE KEY
    );
  }
}
