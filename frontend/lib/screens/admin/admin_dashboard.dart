// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../services/api_service.dart';

// class AdminDashboard extends StatefulWidget {
//   final Map<String, dynamic> adminData;
//   const AdminDashboard({super.key, required this.adminData});

//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }

// class _AdminDashboardState extends State<AdminDashboard> {
//   // FIXED: Starts at 0 so "Overview" is the first screen after login
//   int _selectedIndex = 0; 
//   late Future<Map<String, dynamic>> _statsFuture;
  
//   DateTime _viewDate = DateTime.now();
//   List<dynamic> _dailySlots = [];
//   bool _isLoadingSlots = false;

//   @override
//   void initState() {
//     super.initState();
//     _statsFuture = ApiService.getStressStats();
//     _fetchDailySlots(); 
//   }

//   // --- DATA FETCHING ---

//   Future<void> _fetchDailySlots() async {
//     setState(() => _isLoadingSlots = true);
//     try {
//       final dateStr = DateFormat('yyyy-MM-dd').format(_viewDate);
//       final slots = await ApiService.getSlotsByDate(widget.adminData['id'], dateStr);
//       setState(() => _dailySlots = slots);
//     } catch (e) {
//       debugPrint("Error fetching slots: $e");
//     } finally {
//       setState(() => _isLoadingSlots = false);
//     }
//   }

//   void _handleAppointmentDecision(String id, String status) async {
//     try {
//       await ApiService.updateAppointmentStatus(id, status);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Appointment $status"), backgroundColor: Colors.green),
//       );
//       setState(() {}); // Refresh views
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Action failed: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }

//   void _deleteSlot(String slotId) async {
//     try {
//       await ApiService.deleteSlot(slotId); 
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Slot removed successfully"), backgroundColor: Colors.orange),
//       );
//       _fetchDailySlots(); 
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Delete failed: $e"), backgroundColor: Colors.red),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(
//         backgroundColor: const Color(0xFF800020), 
//         onPressed: _showCreateSlotDialog,
//         child: const Icon(Icons.add, color: Colors.white),
//       ) : null,
//       body: Row(
//         children: [
//           NavigationRail(
//             backgroundColor: const Color(0xFF263238),
//             selectedIndex: _selectedIndex,
//             extended: MediaQuery.of(context).size.width > 800,
//             onDestinationSelected: (index) => setState(() => _selectedIndex = index),
//             leading: const Padding(
//               padding: EdgeInsets.symmetric(vertical: 20),
//               child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF263238))),
//             ),
//             destinations: const [
//               NavigationRailDestination(icon: Icon(Icons.dashboard_outlined, color: Colors.white70), selectedIcon: Icon(Icons.dashboard, color: Colors.white), label: Text("Overview", style: TextStyle(color: Colors.white))),
//               NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined, color: Colors.white70), selectedIcon: Icon(Icons.calendar_month, color: Colors.white), label: Text("Schedule", style: TextStyle(color: Colors.white))),
//               NavigationRailDestination(icon: Icon(Icons.people_outline, color: Colors.white70), selectedIcon: Icon(Icons.people, color: Colors.white), label: Text("Appointments", style: TextStyle(color: Colors.white))),
//               NavigationRailDestination(icon: Icon(Icons.account_circle_outlined, color: Colors.white70), selectedIcon: Icon(Icons.account_circle, color: Colors.white), label: Text("Profile", style: TextStyle(color: Colors.white))),
//             ],
//           ),
//           Expanded(
//             child: _buildMainContent(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMainContent() {
//     switch (_selectedIndex) {
//       case 0:
//         return _buildAnalyticsView();
//       case 1:
//         return _buildScheduleView();
//       case 2:
//         return _buildAppointmentsManagementView();
//       case 3:
//         return _buildProfileView();
//       default:
//         return _buildAnalyticsView();
//     }
//   }

//   // --- VIEW 0: ANALYTICS ---
//   Widget _buildAnalyticsView() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _statsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//         final stats = snapshot.data ?? {"High": 0, "Moderate": 0, "Low": 0};
//         return Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Hello, ${widget.adminData['name']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   _buildStatCard("High Stress", stats['High'].toString(), Colors.redAccent, Icons.trending_up),
//                   const SizedBox(width: 15),
//                   _buildStatCard("Moderate", stats['Moderate'].toString(), Colors.orange, Icons.remove_red_eye),
//                   const SizedBox(width: 15),
//                   _buildStatCard("Low Stress", stats['Low'].toString(), Colors.green, Icons.check_circle_outline),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildStatCard(String title, String count, Color color, IconData icon) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
//         ),
//         child: Column(
//           children: [
//             Icon(icon, color: color, size: 30),
//             const SizedBox(height: 10),
//             Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//             Text(title, style: const TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- VIEW 1: SCHEDULE (TIME SLOTS) ---
//   Widget _buildScheduleView() {
//     return Container(
//       color: const Color(0xFFF9F9F9),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Date Range", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text(DateFormat('MMM dd, yyyy').format(_viewDate), style: const TextStyle(color: Colors.grey)),
//                 ],
//               ),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
//                 onPressed: () async {
//                   final DateTime? picked = await showDatePicker(
//                     context: context,
//                     initialDate: _viewDate,
//                     firstDate: DateTime(2025),
//                     lastDate: DateTime(2030),
//                   );
//                   if (picked != null) {
//                     setState(() => _viewDate = picked);
//                     _fetchDailySlots();
//                   }
//                 },
//                 child: const Text("Change", style: TextStyle(color: Colors.white)),
//               )
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildHorizontalCalendar(),
//           const SizedBox(height: 30),
//           Expanded(
//             child: _isLoadingSlots 
//               ? const Center(child: CircularProgressIndicator())
//               : _dailySlots.isEmpty 
//                 ? const Center(child: Text("No slots created for this day."))
//                 : ListView.builder(
//                     itemCount: _dailySlots.length,
//                     itemBuilder: (context, index) {
//                       final slot = _dailySlots[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(color: Colors.grey.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.person_outline, color: Colors.green),
//                             const SizedBox(width: 15),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("${slot['start_time']} - ${slot['end_time']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                                   Text(slot['is_available'] ? "Available" : "Booked by student", style: const TextStyle(color: Colors.grey)),
//                                 ],
//                               ),
//                             ),
//                             if (slot['is_available']) IconButton(
//                               icon: const Icon(Icons.delete_outline, color: Colors.red),
//                               onPressed: () => _deleteSlot(slot['id']),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHorizontalCalendar() {
//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 7,
//         itemBuilder: (context, index) {
//           DateTime date = _viewDate.add(Duration(days: index - 3));
//           bool isSelected = DateUtils.isSameDay(date, _viewDate);
          
//           return GestureDetector(
//             onTap: () {
//               setState(() => _viewDate = date);
//               _fetchDailySlots();
//             },
//             child: Container(
//               width: 70,
//               margin: const EdgeInsets.only(right: 15),
//               decoration: BoxDecoration(
//                 color: isSelected ? const Color(0xFFD7CCC8) : Colors.transparent,
//                 borderRadius: BorderRadius.circular(10),
//                 border: isSelected ? Border.all(color: const Color(0xFF800020), width: 1) : null,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(DateFormat('EEE').format(date), 
//                     style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
//                   Text(DateFormat('d').format(date), 
//                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                   Text("${isSelected ? _dailySlots.length : 0} slots", 
//                     style: const TextStyle(fontSize: 10, color: Colors.grey)),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // --- VIEW 2: APPOINTMENTS MANAGEMENT ---
//   Widget _buildAppointmentsManagementView() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       color: const Color(0xFFF9F9F9),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Manage Appointment Requests", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 20),
//           Expanded(
//             child: FutureBuilder<List<dynamic>>(
//               future: ApiService.getAllAppointments(), 
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No appointments found."));

//                 return ListView.builder(
//                   itemCount: snapshot.data!.length,
//                   itemBuilder: (context, index) {
//                     final ap = snapshot.data![index];
//                     return Card(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.all(16),
//                         title: Text("${ap['student_name']} (${ap['type']})", style: const TextStyle(fontWeight: FontWeight.bold)),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Ref: ${ap['ref_code']}", style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
//                             Text("Schedule: ${ap['date']} at ${ap['time']}"),
//                             const SizedBox(height: 5),
//                             Text("Status: ${ap['status']}", style: TextStyle(
//                               color: ap['status'] == 'Pending' ? Colors.orange : (ap['status'] == 'Confirmed' ? Colors.green : Colors.red),
//                               fontWeight: FontWeight.bold
//                             )),
//                           ],
//                         ),
//                         trailing: ap['status'] == 'Pending' ? Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
//                               onPressed: () => _handleAppointmentDecision(ap['id'], 'Confirmed'),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
//                               onPressed: () => _handleAppointmentDecision(ap['id'], 'Rejected'),
//                             ),
//                           ],
//                         ) : null,
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // --- VIEW 3: PROFILE ---
//   Widget _buildProfileView() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(40),
//       color: const Color(0xFFF9F9F9),
//       child: Column(
//         children: [
//           const CircleAvatar(
//             radius: 60,
//             backgroundColor: Color(0xFF800020),
//             child: Icon(Icons.person, size: 60, color: Colors.white),
//           ),
//           const SizedBox(height: 20),
//           Text(
//             widget.adminData['name'] ?? "Counselor Name",
//             style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             widget.adminData['email'] ?? "email@msu.edu",
//             style: const TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           const SizedBox(height: 40),
//           const Divider(),
//           const Spacer(),
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF800020),
//               minimumSize: const Size(250, 50),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             icon: const Icon(Icons.logout, color: Colors.white),
//             label: const Text("LOG OUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//             onPressed: () {
//               Navigator.of(context).popUntil((route) => route.isFirst);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   // --- HELPER DIALOGS ---

//   void _showCreateSlotDialog() {
//     TimeOfDay? startTime;
//     TimeOfDay? endTime;

//     showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Center(child: Text("Create Time Slot", style: TextStyle(fontWeight: FontWeight.bold))),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _dialogSelectionTile(
//                 label: "Date",
//                 value: DateFormat('MMMM dd, yyyy').format(_viewDate),
//                 icon: Icons.calendar_today,
//                 onTap: null, 
//               ),
//               _dialogSelectionTile(
//                 label: "Start Time",
//                 value: startTime?.format(context) ?? "Select Time",
//                 icon: Icons.access_time,
//                 onTap: () async {
//                   final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
//                   if (picked != null) setDialogState(() => startTime = picked);
//                 },
//               ),
//               _dialogSelectionTile(
//                 label: "End Time",
//                 value: endTime?.format(context) ?? "Select Time",
//                 icon: Icons.access_time_filled,
//                 onTap: () async {
//                   final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
//                   if (picked != null) setDialogState(() => endTime = picked);
//                 },
//               ),
//             ],
//           ),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
//                 ),
//                 const SizedBox(width: 20),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF800020),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   ),
//                   onPressed: (startTime != null && endTime != null) ? () async {
//                     final dateStr = DateFormat('yyyy-MM-dd').format(_viewDate);
//                     await ApiService.createManualSlot(
//                       widget.adminData['id'], 
//                       dateStr, 
//                       startTime!.format(context), 
//                       endTime!.format(context)
//                     );
//                     Navigator.pop(context);
//                     _fetchDailySlots();
//                   } : null,
//                   child: const Text("Create", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _dialogSelectionTile({required String label, required String value, required IconData icon, required VoidCallback? onTap}) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
//       subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
//       trailing: Icon(icon, color: Colors.black),
//       onTap: onTap,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> adminData;
  const AdminDashboard({super.key, required this.adminData});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0; 
  late Future<Map<String, dynamic>> _statsFuture;
  
  DateTime _viewDate = DateTime.now();
  List<dynamic> _dailySlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getStressStats();
    _fetchDailySlots(); 
  }

  Future<void> _fetchDailySlots() async {
    setState(() => _isLoadingSlots = true);
    try {
      final String? adminId = widget.adminData['id']?.toString();
      if (adminId == null) return;

      final dateStr = DateFormat('yyyy-MM-dd').format(_viewDate);
      final slots = await ApiService.getSlotsByDate(adminId, dateStr);
      setState(() => _dailySlots = slots);
    } catch (e) {
      debugPrint("Error fetching slots: $e");
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  // Logic to Approve or Reject Appointments (the primary decision handler)
  void _handleAppointmentDecision(dynamic id, String status) {
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Appointment ID is missing")),
      );
      return;
    }

    final TextEditingController _notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add Remarks for $status", 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Are you sure you want to $status this appointment?", 
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter notes or instructions for the student...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'Confirmed' ? Colors.green : Colors.red,
            ),
            onPressed: () => _handleFinalDecision(id.toString(), status, _notesController.text),
            child: Text("Submit $status", style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- FIXED: ADDED THE MISSING HELPER METHOD ---
  void _handleFinalDecision(String id, String status, String notes) async {
    try {
      // Calls the API to update both status and notes in Neo4j
      await ApiService.updateAppointmentStatus(id, status, notes: notes);
      
      if (!mounted) return;
      
      // Use popUntil to clear all open dialogs (Credentials and the Note pop-up)
      Navigator.popUntil(context, (route) => route.isFirst || _selectedIndex == 2);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Appointment $status successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      
      setState(() {}); // Refresh the dashboard list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showStudentCredentials(dynamic ap) {
    final TextEditingController _liveNotesController = 
        TextEditingController(text: ap['notes'] ?? "");
    final String apId = ap['id']?.toString() ?? "";
    final String currentStatus = ap['status'] ?? "Pending";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Manage: ${ap['student_name'] ?? 'Unknown'}", 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(Icons.email, "Email", ap['email'] ?? 'N/A'),
              _detailRow(Icons.phone, "Contact", ap['contact'] ?? 'N/A'),
              _detailRow(Icons.description, "Reason", ap['reason'] ?? 'No reason provided'),
              const Divider(height: 30),
              const Text("Counselor Notes & Remarks:", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: _liveNotesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Update your session notes or remarks here...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          
          if (currentStatus == 'Pending') ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
              onPressed: () => _handleFinalDecision(apId, 'Rejected', _liveNotesController.text),
              child: const Text("Reject", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
              onPressed: () => _handleFinalDecision(apId, 'Confirmed', _liveNotesController.text),
              child: const Text("Confirm", style: TextStyle(color: Colors.white)),
            ),
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
              onPressed: () => _handleFinalDecision(apId, currentStatus, _liveNotesController.text),
              child: const Text("Update Remarks", style: TextStyle(color: Colors.white)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF800020)),
          const SizedBox(width: 10),
          Expanded(child: Text("$label: $value", style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _deleteSlot(dynamic slotId) async {
    if (slotId == null) return;
    try {
      await ApiService.deleteSlot(slotId.toString()); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Slot removed successfully"), backgroundColor: Colors.orange),
      );
      _fetchDailySlots(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _selectedIndex == 1 ? FloatingActionButton(
        backgroundColor: const Color(0xFF800020), 
        onPressed: _showCreateSlotDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: const Color(0xFF263238),
            selectedIndex: _selectedIndex,
            extended: MediaQuery.of(context).size.width > 800,
            onDestinationSelected: (index) => setState(() => _selectedIndex = index),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Color(0xFF263238))),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined, color: Colors.white70), selectedIcon: Icon(Icons.dashboard, color: Colors.white), label: Text("Overview", style: TextStyle(color: Colors.white))),
              NavigationRailDestination(icon: Icon(Icons.calendar_month_outlined, color: Colors.white70), selectedIcon: Icon(Icons.calendar_month, color: Colors.white), label: Text("Schedule", style: TextStyle(color: Colors.white))),
              NavigationRailDestination(icon: Icon(Icons.people_outline, color: Colors.white70), selectedIcon: Icon(Icons.people, color: Colors.white), label: Text("Appointments", style: TextStyle(color: Colors.white))),
              NavigationRailDestination(icon: Icon(Icons.account_circle_outlined, color: Colors.white70), selectedIcon: Icon(Icons.account_circle, color: Colors.white), label: Text("Profile", style: TextStyle(color: Colors.white))),
            ],
          ),
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0: return _buildAnalyticsView();
      case 1: return _buildScheduleView();
      case 2: return _buildAppointmentsManagementView();
      case 3: return _buildProfileView();
      default: return _buildAnalyticsView();
    }
  }

  Widget _buildAnalyticsView() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final stats = snapshot.data ?? {"High": 0, "Moderate": 0, "Low": 0};
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hello, ${widget.adminData['name'] ?? 'Counselor'}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              Row(
                children: [
                  _buildStatCard("High Stress", (stats['High'] ?? 0).toString(), Colors.redAccent, Icons.trending_up),
                  const SizedBox(width: 15),
                  _buildStatCard("Moderate", (stats['Moderate'] ?? 0).toString(), Colors.orange, Icons.remove_red_eye),
                  const SizedBox(width: 15),
                  _buildStatCard("Low Stress", (stats['Low'] ?? 0).toString(), Colors.green, Icons.check_circle_outline),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(count, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleView() {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Date Range", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(DateFormat('MMM dd, yyyy').format(_viewDate), style: const TextStyle(color: Colors.grey)),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context, initialDate: _viewDate, firstDate: DateTime(2025), lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => _viewDate = picked);
                    _fetchDailySlots();
                  }
                },
                child: const Text("Change", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
          const SizedBox(height: 20),
          _buildHorizontalCalendar(),
          const SizedBox(height: 30),
          Expanded(
            child: _isLoadingSlots 
              ? const Center(child: CircularProgressIndicator())
              : _dailySlots.isEmpty 
                ? const Center(child: Text("No slots created for this day."))
                : ListView.builder(
                    itemCount: _dailySlots.length,
                    itemBuilder: (context, index) {
                      final slot = _dailySlots[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: Colors.green),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${slot['start_time'] ?? 'N/A'} - ${slot['end_time'] ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text((slot['is_available'] ?? true) ? "Available" : "Booked by student", style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            if (slot['is_available'] == true) IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteSlot(slot['id']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = _viewDate.add(Duration(days: index - 3));
          bool isSelected = DateUtils.isSameDay(date, _viewDate);
          return GestureDetector(
            onTap: () {
              setState(() => _viewDate = date);
              _fetchDailySlots();
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFD7CCC8) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: const Color(0xFF800020), width: 1) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date), style: TextStyle(color: isSelected ? Colors.black : Colors.grey)),
                  Text(DateFormat('d').format(date), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("${isSelected ? _dailySlots.length : 0} slots", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsManagementView() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF9F9F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Manage Appointment Requests", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: ApiService.getAllAppointments(), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No appointments found."));

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final ap = snapshot.data![index];
                    final dynamic apId = ap['id'];

                    return InkWell(
                      onTap: () => _showStudentCredentials(ap), 
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text("${ap['student_name'] ?? 'Unknown'} (${ap['type'] ?? 'N/A'})", style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ref: ${ap['ref_code'] ?? 'N/A'}", style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                              Text("Schedule: ${ap['date'] ?? 'N/A'} at ${ap['time'] ?? 'N/A'}"),
                              const SizedBox(height: 5),
                              Text("Status: ${ap['status'] ?? 'Pending'}", style: TextStyle(
                                color: ap['status'] == 'Pending' ? Colors.orange : (ap['status'] == 'Confirmed' ? Colors.green : Colors.red),
                                fontWeight: FontWeight.bold
                              )),
                            ],
                          ),
                          trailing: ap['status'] == 'Pending' ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                                onPressed: () => _handleAppointmentDecision(apId, 'Confirmed'),
                              ),
                              IconButton(
                                icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                                onPressed: () => _handleAppointmentDecision(apId, 'Rejected'),
                              ),
                            ],
                          ) : null,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(40), color: const Color(0xFFF9F9F9),
      child: Column(
        children: [
          const CircleAvatar(radius: 60, backgroundColor: Color(0xFF800020), child: Icon(Icons.person, size: 60, color: Colors.white)),
          const SizedBox(height: 20),
          Text(widget.adminData['name'] ?? "Counselor Name", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(widget.adminData['email'] ?? "email@msu.edu", style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
          const Divider(),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020), minimumSize: const Size(250, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("LOG OUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ),
    );
  }

  void _showCreateSlotDialog() {
    TimeOfDay? startTime;
    TimeOfDay? endTime;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text("Create Time Slot", style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogSelectionTile(label: "Date", value: DateFormat('MMMM dd, yyyy').format(_viewDate), icon: Icons.calendar_today, onTap: null),
              _dialogSelectionTile(label: "Start Time", value: startTime?.format(context) ?? "Select Time", icon: Icons.access_time, onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setDialogState(() => startTime = picked);
              }),
              _dialogSelectionTile(label: "End Time", value: endTime?.format(context) ?? "Select Time", icon: Icons.access_time_filled, onTap: () async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) setDialogState(() => endTime = picked);
              }),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: (startTime != null && endTime != null) ? () async {
                    final dateStr = DateFormat('yyyy-MM-dd').format(_viewDate);
                    final String? adminId = widget.adminData['id']?.toString();
                    if (adminId == null) return;
                    await ApiService.createManualSlot(adminId, dateStr, startTime!.format(context), endTime!.format(context));
                    Navigator.pop(context);
                    _fetchDailySlots();
                  } : null,
                  child: const Text("Create", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogSelectionTile({required String label, required String value, required IconData icon, required VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      trailing: Icon(icon, color: Colors.black),
      onTap: onTap,
    );
  }
}