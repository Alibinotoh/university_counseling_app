// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/api_service.dart';

// class BookingScreen extends StatefulWidget {
//   const BookingScreen({super.key});

//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends State<BookingScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // Controllers for ALL fields required by your backend model
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _contactController = TextEditingController(); // Added
//   final _reasonController = TextEditingController();  // Added
//   String _userType = "Student";

//   List<dynamic> _counselors = []; 
//   String? _selectedCounselorId;
//   DateTime _selectedDate = DateTime.now();
//   List<dynamic> _availableSlots = [];
//   String? _selectedSlotId;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCounselors();
//   }

//   Future<void> _fetchCounselors() async {
//     try {
//       final data = await ApiService.getAllCounselors();
//       setState(() {
//         _counselors = data;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       debugPrint("Error: $e");
//     }
//   }

//   // booking_screen.dart
//   Future<void> _loadSlots() async {
//     if (_selectedCounselorId == null) return;
    
//     // Format date to match your Neo4j stored format (YYYY-MM-DD)
//     final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
//     try {
//       // This calls your API: GET /api/v1/slots/available?counselor_id=...&date=...
//       final slots = await ApiService.getSlotsByDate(_selectedCounselorId!, dateStr);
//       setState(() {
//         _availableSlots = slots;
//         _selectedSlotId = null; // Clear previous selection when list refreshes
//       });
//     } catch (e) {
//       debugPrint("Error loading real-time slots: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Book Appointment")),
//       body: _isLoading 
//         ? const Center(child: CircularProgressIndicator())
//         : Form(
//             key: _formKey,
//             child: ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
//                 DropdownButtonFormField(
//                   value: _userType,
//                   items: ["Student", "Employee"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
//                   onChanged: (val) => setState(() => _userType = val as String),
//                 ),
//                 TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
//                 // FIXED: Missing Contact Field
//                 TextFormField(controller: _contactController, decoration: const InputDecoration(labelText: "Contact Number")),
//                 // FIXED: Missing Reason Field
//                 TextFormField(controller: _reasonController, decoration: const InputDecoration(labelText: "Reason for Appointment (Optional)")),
                
//                 const SizedBox(height: 30),
//                 const Text("Select Counselor & Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
//                 DropdownButtonFormField<String>(
//                   hint: const Text("Select Counselor"),
//                   value: _selectedCounselorId, // Link to your state variable
//                   items: _counselors.map((c) {
//                     return DropdownMenuItem<String>(
//                       value: c['id'].toString(), // Use the ID from Neo4j
//                       child: Text(c['name'] ?? "Unknown Counselor"), // Display the name
//                     );
//                   }).toList(),
//                   onChanged: (val) {
//                     setState(() {
//                       _selectedCounselorId = val;
//                       _selectedSlotId = null; // Reset slot when counselor changes
//                     });
//                     _loadSlots(); // Refresh slots for the new counselor
//                   },
//                   validator: (value) => value == null ? 'Please select a counselor' : null,
//                 ),
                
//                 ListTile(
//                   title: Text("Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}"),
//                   trailing: const Icon(Icons.calendar_month),
//                   onTap: () async {
//                     final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027));
//                     if (picked != null) {
//                       setState(() => _selectedDate = picked);
//                       _loadSlots();
//                     }
//                   },
//                 ),

//                 // Inside your ListView in booking_screen.dart
//                 const Text("Available Time Slots:", style: TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 10),

//                 _availableSlots.isEmpty 
//                   ? const Text("No available slots for this date.", style: TextStyle(color: Colors.grey))
//                   : Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       children: _availableSlots.map((slot) {
//                         bool isSelected = _selectedSlotId == slot['id'];
//                         return ChoiceChip(
//                           label: Text("${slot['start_time']} - ${slot['end_time']}"),
//                           selected: isSelected,
//                           selectedColor: const Color(0xFF800020), // Matches your MSU theme
//                           labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
//                           onSelected: (selected) {
//                             setState(() => _selectedSlotId = slot['id']);
//                           },
//                         );
//                       }).toList(),
//                     ),

//                 const SizedBox(height: 40),
//                 ElevatedButton(
//                   onPressed: _submitBooking,
//                   style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020), foregroundColor: Colors.white),
//                   child: const Text("Submit Appointment Request"),
//                 )
//               ],
//             ),
//           ),
//     );
//   }

//   void _submitBooking() async {
//     if (!_formKey.currentState!.validate() || _selectedSlotId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
//       return;
//     }

//     try {
//       final result = await ApiService.bookAppointment(
//         name: _nameController.text,
//         type: _userType,
//         email: _emailController.text,
//         contact: _contactController.text,
//         reason: _reasonController.text,
//         counselorId: _selectedCounselorId!,
//         timeslotId: _selectedSlotId!,
//       );
//       _showSuccess(result['reference_code']);
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     }
//   }

//   void _showSuccess(String ref) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Confirmed"),
//         content: Text("Your Reference Code: $ref"),
//         actions: [TextButton(onPressed: () => Navigator.popUntil(context, (r) => r.isFirst), child: const Text("OK"))],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:share_plus/share_plus.dart'; // Required for sharing

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController(); 
  final _reasonController = TextEditingController();  
  String _userType = "Student";

  List<dynamic> _counselors = []; 
  String? _selectedCounselorId;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _availableSlots = [];
  String? _selectedSlotId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCounselors();
  }

  Future<void> _fetchCounselors() async {
    try {
      final data = await ApiService.getAllCounselors();
      setState(() {
        _counselors = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Error: $e");
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedCounselorId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
    try {
      final slots = await ApiService.getSlotsByDate(_selectedCounselorId!, dateStr);
      setState(() {
        // Ensure we only show slots where is_available is true
        _availableSlots = slots.where((s) => s['is_available'] == true).toList();
        _selectedSlotId = null; 
      });
    } catch (e) {
      debugPrint("Error loading real-time slots: $e");
    }
  }

  // --- NEW: STEP 1 - TRIGGER THE SUMMARY POP-UP ---
  void _submitBooking() {
    if (!_formKey.currentState!.validate() || _selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields and select a time slot.")),
      );
      return;
    }

    // Get the display details for the selected slot and counselor
    final selectedSlot = _availableSlots.firstWhere((s) => s['id'] == _selectedSlotId);
    final counselorName = _counselors.firstWhere((c) => c['id'] == _selectedCounselorId)['name'];

    _showBookingSummary(counselorName, selectedSlot);
  }

  // --- NEW: STEP 2 - THE SUMMARY DIALOG UI ---
  void _showBookingSummary(String counselor, dynamic slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow(Icons.person, "Counselor", counselor),
            _summaryRow(Icons.calendar_today, "Date", DateFormat('MMMM dd, yyyy').format(_selectedDate)),
            _summaryRow(Icons.access_time, "Time", "${slot['start_time']} - ${slot['end_time']}"),
            const Divider(height: 30),
            const Text("Note: You will receive a reference code after confirming.", 
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Edit Details", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
            onPressed: () {
              Navigator.pop(context); // Close summary
              _finalSubmit(); // Trigger actual API call
            },
            child: const Text("Confirm & Book", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF800020)),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // --- NEW: STEP 3 - FINAL API SUBMISSION ---
  void _finalSubmit() async {
    // Show loading indicator during network request
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await ApiService.bookAppointment(
        name: _nameController.text,
        type: _userType,
        email: _emailController.text,
        contact: _contactController.text,
        reason: _reasonController.text.isEmpty ? "No reason provided" : _reasonController.text,
        counselorId: _selectedCounselorId!,
        timeslotId: _selectedSlotId!,
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loader
      _showSuccess(result['reference_code']);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text("Personal Information", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: "Full Name")),
                DropdownButtonFormField(
                  value: _userType,
                  items: ["Student", "Employee"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) => setState(() => _userType = val as String),
                ),
                TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
                TextFormField(controller: _contactController, decoration: const InputDecoration(labelText: "Contact Number")),
                TextFormField(controller: _reasonController, decoration: const InputDecoration(labelText: "Reason for Appointment (Optional)")),
                
                const SizedBox(height: 30),
                const Text("Select Counselor & Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
                DropdownButtonFormField<String>(
                  hint: const Text("Select Counselor"),
                  value: _selectedCounselorId, 
                  items: _counselors.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['id'].toString(), 
                      child: Text(c['name'] ?? "Unknown Counselor"), 
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCounselorId = val;
                      _selectedSlotId = null; 
                    });
                    _loadSlots(); 
                  },
                  validator: (value) => value == null ? 'Please select a counselor' : null,
                ),
                
                ListTile(
                  title: Text("Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}"),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027));
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _loadSlots();
                    }
                  },
                ),

                const Text("Available Time Slots:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                _availableSlots.isEmpty 
                  ? const Text("No available slots for this date.", style: TextStyle(color: Colors.grey))
                  : Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _availableSlots.map((slot) {
                        bool isSelected = _selectedSlotId == slot['id'];
                        return ChoiceChip(
                          label: Text("${slot['start_time']} - ${slot['end_time']}"),
                          selected: isSelected,
                          selectedColor: const Color(0xFF800020), 
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          onSelected: (selected) {
                            setState(() => _selectedSlotId = slot['id']);
                          },
                        );
                      }).toList(),
                    ),

                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _submitBooking,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020), foregroundColor: Colors.white),
                  child: const Text("Submit Appointment Request"),
                )
              ],
            ),
          ),
    );
  }

  void _showSuccess(String ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text("Booking Confirmed!", style: TextStyle(fontWeight: FontWeight.bold))
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please save your reference code. You will need this to track your appointment status.",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),
            
            // --- THE CODE BOX ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF800020), width: 1),
              ),
              child: Text(
                ref,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF800020)),
              ),
            ),
            const SizedBox(height: 20),

            // --- ACTION BUTTONS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // COPY BUTTON
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  tooltip: "Copy to Clipboard",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ref));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code copied to clipboard!")),
                    );
                  },
                ),
                // SHARE / DOWNLOAD BUTTON
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.green),
                  tooltip: "Share or Save",
                  onPressed: () {
                    Share.share(
                      "My MSU Guidance Appointment Reference Code is: $ref\nCheck status at the Guidance App.",
                      subject: "Guidance Appointment Code",
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800020),
                minimumSize: const Size(120, 45),
              ),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("OK", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}