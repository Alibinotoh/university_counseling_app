import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../session_gate.dart';

class AdminProfile extends StatelessWidget {
  final Map<String, dynamic> adminData;
  const AdminProfile({super.key, required this.adminData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF9F9F9), 
      child: Column(
        children: [
          const SizedBox(height: 40),
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF800020),
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            adminData['name'] ?? "Counselor", 
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            adminData['email'] ?? "admin@msu.edu", 
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Divider(thickness: 1),
          const Spacer(),
          
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800020),
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              "LOG OUT", 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              )
            ),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();

              // 🔥 FULL SESSION WIPE (WEB-SAFE)
              await prefs.clear();

              // 🔁 Small delay to let browser flush localStorage
              await Future.delayed(const Duration(milliseconds: 100));

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SessionGate()),
                (route) => false,
              );
            }


          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}