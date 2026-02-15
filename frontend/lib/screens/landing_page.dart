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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Track Appointment"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Enter Reference Code (e.g. ABCD-1234)",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            // Inside _showStatusCheck ElevatedButton onPressed
            onPressed: () async {
              if (controller.text.isEmpty) return;
              
              String enteredRef = controller.text.trim(); // Capture the code
              
              try {
                final statusData = await ApiService.checkAppointmentStatus(enteredRef);
                if (!mounted) return;
                
                Navigator.pop(context); // Close the input dialog
                
                // FIXED: Pass both the data and the reference code
                _showStatusResult(statusData, enteredRef); 
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Invalid Reference Code. Please try again."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Check"),
          )
        ],
      ),
    );
  }

  // --- 2. FUNCTION TO DISPLAY THE RETRIEVED STATUS ---
  void _showStatusResult(Map<String, dynamic> data, String refCode) {
    // Logic to determine color based on status
    Color statusColor = Colors.orange; // Default for Pending
    if (data['status'] == 'Confirmed') statusColor = Colors.green;
    if (data['status'] == 'Rejected') statusColor = Colors.red;
    if (data['status'] == 'Cancelled') statusColor = Colors.grey;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Appointment Details", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Counselor: ${data['counselor_name'] ?? 'Not Assigned'}"),
            Text("Date: ${data['date'] ?? 'N/A'}"),
            Text("Time: ${data['start_time'] ?? 'N/A'} - ${data['end_time'] ?? 'N/A'}"),
            const Divider(height: 30),
            
            // --- NEW: COUNSELOR REMARKS SECTION ---
            const Text("COUNSELOR REMARKS:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 5),
            Text(
              data['notes'] ?? "No additional remarks from the counselor.",
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black87),
            ),
            
            const SizedBox(height: 20),
            const Text("CURRENT STATUS:", style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(
              (data['status'] ?? 'UNKNOWN').toString().toUpperCase(),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: statusColor),
            ),
          ],
        ),
        actions: [
          // Show Cancel button only for PENDING appointments
          if (data['status'] == 'Pending')
            TextButton(
              onPressed: () => _confirmCancellation(refCode),
              child: const Text("Cancel Appointment", style: TextStyle(color: Colors.red)),
            ),
            
          // Show Receipt button only for CONFIRMED appointments
          if (data['status'] == 'Confirmed')
            TextButton.icon(
              onPressed: () => _generateAppointmentReceipt(data, refCode),
              icon: const Icon(Icons.receipt_long, color: Colors.green),
              label: const Text("Receipt", style: TextStyle(color: Colors.green)),
            ),
            
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
    );
  }

  // --- ADD THESE INSIDE _LandingPageState in landing_page.dart ---
  void _generateAppointmentReceipt(Map<String, dynamic> data, String refCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            const Text("OFFICIAL RECEIPT", 
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF800020))),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),
            _receiptRow("Ref Code:", refCode),
            _receiptRow("Counselor:", data['counselor_name'] ?? 'Not Assigned'),
            _receiptRow("Date:", data['date'] ?? 'N/A'),
            _receiptRow("Time:", "${data['start_time'] ?? 'N/A'} - ${data['end_time'] ?? 'N/A'}"),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Please present this receipt or a screenshot upon arrival at the MSU-TCTO Guidance Office.",
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold))
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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