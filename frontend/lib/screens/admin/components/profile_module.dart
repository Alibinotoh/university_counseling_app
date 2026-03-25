import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../session_gate.dart';

class ProfileModule extends StatelessWidget {
  final Map<String, dynamic> adminData;
  final Color msuMaroon;
  final Color surfaceColor;
  final Color colorSlateText;

  const ProfileModule({
    super.key,
    required this.adminData,
    required this.msuMaroon,
    required this.surfaceColor,
    required this.colorSlateText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: surfaceColor, 
          borderRadius: BorderRadius.circular(24), 
          border: Border.all(color: Colors.grey.withOpacity(0.1))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 50, backgroundColor: msuMaroon, child: const Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            Text(adminData['name'] ?? "Counselor", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(adminData['email'] ?? "admin@msu.edu", style: TextStyle(color: colorSlateText)),
            const Divider(height: 40),
            _profileTile(Icons.security, "Security Settings"),
            _profileTile(Icons.notifications_active_outlined, "Notifications"),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: msuMaroon, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => _logout(context),
                child: const Text("SIGN OUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(IconData i, String t) => ListTile(leading: Icon(i, size: 20), title: Text(t, style: const TextStyle(fontSize: 14)), trailing: const Icon(Icons.chevron_right, size: 16));

  void _logout(BuildContext context) async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const SessionGate()), (r) => false);
  }
}