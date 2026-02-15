import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/landing_page.dart';
import 'screens/admin/admin_dashboard.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  Map<String, dynamic>? adminData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('admin_token');
      final data = prefs.getString('admin_data');

      // ✅ Require BOTH token and data
      if (token != null && data != null) {
        adminData = jsonDecode(data);
      } else {
        adminData = null;
      }
    } catch (e) {
      // ❌ If JSON is broken or prefs fail
      adminData = null;
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return adminData != null
        ? AdminDashboard(adminData: adminData!)
        : const LandingPage();
  }
}
