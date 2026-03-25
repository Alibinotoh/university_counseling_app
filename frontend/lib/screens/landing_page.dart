import 'package:flutter/material.dart';
import 'assessment_screen.dart';
import 'booking_screen.dart'; 
import 'admin/admin_login_screen.dart'; 
import '../services/api_service.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _adminTapCount = 0; // Tracks taps for the hidden trigger

  // --- 1. FUNCTION TO SHOW THE STATUS INPUT DIALOG ---
  void _showStatusCheck() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          left: 24, right: 24, top: 32
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            const Text("Track Appointment", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            const Text("Enter your unique reference code below.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: "E.G. ABCD-1234",
                hintStyle: const TextStyle(letterSpacing: 0, fontWeight: FontWeight.normal),
                prefixIcon: const Icon(Icons.qr_code_scanner, color: Color(0xFF800020)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () async {
                if (controller.text.isEmpty) return;
                String enteredRef = controller.text.trim().toUpperCase();
                
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                
                try {
                  final statusData = await ApiService.checkAppointmentStatus(enteredRef);
                  if (!mounted) return;
                  Navigator.pop(context); // Remove loader
                  Navigator.pop(context); // Close BottomSheet
                  _showStatusResult(statusData, enteredRef);
                } catch (e) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid code.")));
                }
              },
              child: const Text("View Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. FUNCTION TO DISPLAY THE RETRIEVED STATUS ---
  void _showStatusResult(Map<String, dynamic> data, String refCode) {
    final String status = (data['status'] ?? 'Pending').toString();
    
    // Status Logic mapping
    Color statusColor = Colors.orange;
    IconData statusIcon = Icons.hourglass_empty;
    if (status == 'Confirmed') { statusColor = Colors.green; statusIcon = Icons.check_circle; }
    else if (status == 'Rejected') { statusColor = Colors.red; statusIcon = Icons.cancel; }
    else if (status == 'Cancelled') { statusColor = Colors.grey; statusIcon = Icons.block; }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Text(status.toUpperCase(), style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _detailRow("Counselor", data['counselor_name'] ?? 'To be assigned'),
            _detailRow("Date", data['date'] ?? 'N/A'),
            _detailRow("Time", "${data['start_time']} - ${data['end_time']}"),
            const Divider(height: 32),
            const Align(alignment: Alignment.centerLeft, child: Text("REMARKS:", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 8),
            Text(data['notes'] ?? "No remarks yet.", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          if (status == 'Pending')
            TextButton(onPressed: () => _confirmCancellation(refCode), child: const Text("Cancel Appointment", style: TextStyle(color: Colors.red))),
          if (status == 'Confirmed')
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _generateAppointmentReceipt(data, refCode),
              icon: const Icon(Icons.receipt_long, size: 18, color: Colors.white),
              label: const Text("View Receipt", style: TextStyle(color: Colors.white)),
            ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  // Helper for rows
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  // --- ADD THESE INSIDE _LandingPageState in landing_page.dart ---
  void _generateAppointmentReceipt(Map<String, dynamic> data, String refCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Sharp ticket edges
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("MSU-TCTO", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
            const Text("GUIDANCE & COUNSELING OFFICE", style: TextStyle(fontSize: 9, letterSpacing: 1.5)),
            const SizedBox(height: 15),
            const Text("********************************", style: TextStyle(color: Colors.grey)),
            const Text("OFFICIAL APPOINTMENT SLIP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const Text("********************************", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            _receiptLine("REF CODE", refCode),
            _receiptLine("DATE", data['date']),
            _receiptLine("TIME", "${data['start_time']} - ${data['end_time']}"),
            _receiptLine("COUNSELOR", data['counselor_name']),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Present this slip or a screenshot upon arrival.", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("DONE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))))],
      ),
    );
  }

  Widget _receiptLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          Text(value.toString().toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmCancellation(String refCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("This will cancel your appointment and release the time slot."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await ApiService.cancelAppointment(refCode);
                if (!mounted) return;
                Navigator.pop(context); // Close confirm
                Navigator.pop(context); // Close status details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Appointment cancelled successfully")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Error cancelling appointment")),
                );
              }
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- REST OF YOUR UI REMAINS THE SAME ---
  void _handleAdminTrigger() {
    _adminTapCount++;
    if (_adminTapCount >= 5) {
      _adminTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/background.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.fact_check_outlined, color: Colors.white),
                onPressed: _showStatusCheck,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _handleAdminTrigger,
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Image.asset('assets/msu_logo.png'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "MSU-TCTO",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Guidance & Counseling",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Your mental health matters.",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    _buildMenuCard(
                      title: "Self-Assessment",
                      subtitle: "Take a quick assessment to understand your mental health",
                      icon: Icons.assignment_outlined,
                      iconColor: Colors.deepPurple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AssessmentScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuCard(
                      title: "Book Appointment",
                      subtitle: "Schedule a session with our counselors",
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.redAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BookingScreen()),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      "All Information is confidential",
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          ),
        ),
      ),
    );
  }
}