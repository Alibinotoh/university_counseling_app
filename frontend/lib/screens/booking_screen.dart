// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../services/api_service.dart';
// import 'package:flutter/services.dart'; 
// import 'package:share_plus/share_plus.dart'; 

// class BookingScreen extends StatefulWidget {
//   // ADDED: Accept initialReason from Assessment
//   final String? initialReason;
//   const BookingScreen({super.key, this.initialReason});

//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends State<BookingScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _contactController = TextEditingController(); 
  
//   // MODIFIED: Controller initialized later to handle initialReason
//   late TextEditingController _reasonController;  
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
//     // MODIFIED: Pre-fill reason if it exists
//     _reasonController = TextEditingController(text: widget.initialReason ?? "");
//     _fetchCounselors();
//   }

//   @override
//   void dispose() {
//     // Clean up controllers
//     _nameController.dispose();
//     _emailController.dispose();
//     _contactController.dispose();
//     _reasonController.dispose();
//     super.dispose();
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

//   Future<void> _loadSlots() async {
//     if (_selectedCounselorId == null) return;
//     final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    
//     try {
//       final slots = await ApiService.getSlotsByDate(_selectedCounselorId!, dateStr);
//       setState(() {
//         _availableSlots = slots.where((s) => s['is_available'] == true).toList();
//         _selectedSlotId = null; 
//       });
//     } catch (e) {
//       debugPrint("Error loading real-time slots: $e");
//     }
//   }

//   void _submitBooking() {
//     if (!_formKey.currentState!.validate() || _selectedSlotId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please complete all fields and select a time slot.")),
//       );
//       return;
//     }

//     final selectedSlot = _availableSlots.firstWhere((s) => s['id'] == _selectedSlotId);
//     final counselorName = _counselors.firstWhere((c) => c['id'] == _selectedCounselorId)['name'];

//     _showBookingSummary(counselorName, selectedSlot);
//   }

//   void _showBookingSummary(String counselor, dynamic slot) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Confirm Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _summaryRow(Icons.person, "Counselor", counselor),
//             _summaryRow(Icons.calendar_today, "Date", DateFormat('MMMM dd, yyyy').format(_selectedDate)),
//             _summaryRow(Icons.access_time, "Time", "${slot['start_time']} - ${slot['end_time']}"),
//             const Divider(height: 30),
//             const Text("Note: You will receive a reference code after confirming.", 
//               style: TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), 
//             child: const Text("Edit Details", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
//             onPressed: () {
//               Navigator.pop(context); 
//               _finalSubmit(); 
//             },
//             child: const Text("Confirm & Book", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _summaryRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: const Color(0xFF800020)),
//           const SizedBox(width: 10),
//           Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
//           Expanded(child: Text(value)),
//         ],
//       ),
//     );
//   }

//   void _finalSubmit() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => const Center(child: CircularProgressIndicator()),
//     );

//     try {
//       final result = await ApiService.bookAppointment(
//         name: _nameController.text,
//         type: _userType,
//         email: _emailController.text,
//         contact: _contactController.text,
//         reason: _reasonController.text.isEmpty ? "No reason provided" : _reasonController.text,
//         counselorId: _selectedCounselorId!,
//         timeslotId: _selectedSlotId!,
//       );

//       if (!mounted) return;
//       Navigator.pop(context); 
//       _showSuccess(result['reference_code']);
//     } catch (e) {
//       if (!mounted) return;
//       Navigator.pop(context); 
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Failed: $e")));
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
//                 TextFormField(
//                   controller: _nameController, 
//                   decoration: const InputDecoration(labelText: "Full Name"),
//                   validator: (val) => val!.isEmpty ? "Required" : null,
//                 ),
//                 DropdownButtonFormField(
//                   value: _userType,
//                   items: ["Student", "Employee"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
//                   onChanged: (val) => setState(() => _userType = val as String),
//                 ),
//                 TextFormField(
//                   controller: _emailController, 
//                   decoration: const InputDecoration(labelText: "Email"),
//                   validator: (val) => val!.isEmpty ? "Required" : null,
//                 ),
//                 TextFormField(
//                   controller: _contactController, 
//                   decoration: const InputDecoration(labelText: "Contact Number"),
//                   validator: (val) => val!.isEmpty ? "Required" : null,
//                 ),
//                 // Reason TextField is now linked to our pre-filled controller
//                 TextFormField(
//                   controller: _reasonController, 
//                   maxLines: 2,
//                   decoration: const InputDecoration(labelText: "Reason for Appointment"),
//                 ),
                
//                 const SizedBox(height: 30),
//                 const Text("Select Counselor & Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                
//                 DropdownButtonFormField<String>(
//                   hint: const Text("Select Counselor"),
//                   value: _selectedCounselorId, 
//                   items: _counselors.map((c) {
//                     return DropdownMenuItem<String>(
//                       value: c['id'].toString(), 
//                       child: Text(c['name'] ?? "Unknown Counselor"), 
//                     );
//                   }).toList(),
//                   onChanged: (val) {
//                     setState(() {
//                       _selectedCounselorId = val;
//                       _selectedSlotId = null; 
//                     });
//                     _loadSlots(); 
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
//                           selectedColor: const Color(0xFF800020), 
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
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF800020), 
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50)
//                   ),
//                   child: const Text("Submit Appointment Request"),
//                 )
//               ],
//             ),
//           ),
//     );
//   }

//   void _showSuccess(String ref) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Center(
//           child: Text("Booking Confirmed!", style: TextStyle(fontWeight: FontWeight.bold))
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Please save your reference code. You will need this to track your appointment status.",
//                 textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
//             const SizedBox(height: 20),
            
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: const Color(0xFF800020), width: 1),
//               ),
//               child: Text(
//                 ref,
//                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF800020)),
//               ),
//             ),
//             const SizedBox(height: 20),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.copy, color: Colors.blue),
//                   onPressed: () {
//                     Clipboard.setData(ClipboardData(text: ref));
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code copied!")));
//                   },
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.share, color: Colors.green),
//                   onPressed: () {
//                     Share.share("My Reference Code: $ref", subject: "Guidance Appointment");
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           Center(
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF800020)),
//               onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
//               child: const Text("OK", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:flutter/services.dart'; 
import 'package:share_plus/share_plus.dart'; 

class BookingScreen extends StatefulWidget {
  final String? initialReason;
  const BookingScreen({super.key, this.initialReason});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

// Added TickerProvider for the breathing animation
class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController(); 
  late TextEditingController _reasonController;  
  
  String _userType = "Student";
  List<dynamic> _counselors = []; 
  String? _selectedCounselorId;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _availableSlots = [];
  String? _selectedSlotId;
  bool _isLoading = true;

  final Color primaryColor = const Color(0xFF800020); // Burgundy branding

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.initialReason ?? "");
    _fetchCounselors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  // --- API LOGIC ---

  Future<void> _fetchCounselors() async {
    try {
      final data = await ApiService.getAllCounselors();
      // Artificial delay to appreciate the Shimmer effect
      await Future.delayed(const Duration(seconds: 2));
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
        _availableSlots = slots.where((s) => s['is_available'] == true).toList();
        _selectedSlotId = null; 
      });
    } catch (e) {
      debugPrint("Error loading real-time slots: $e");
    }
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate() || _selectedSlotId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields and select a time slot.")),
      );
      return;
    }

    final selectedSlot = _availableSlots.firstWhere((s) => s['id'] == _selectedSlotId);
    final counselorName = _counselors.firstWhere((c) => c['id'].toString() == _selectedCounselorId)['name'];

    _showBookingSummary(counselorName, selectedSlot);
  }

  void _finalSubmit() async {
    // Show the custom Breathing Loader instead of standard Progress Indicator
    _showBreathingLoader();

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
      Navigator.pop(context); // Remove Breathing Loader
      _showSuccess(result['reference_code']);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking Failed: $e")));
    }
  }

  // --- UI BUILDING ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Book Appointment", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
        ? _buildShimmerLoading() // Polished Shimmer
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Personal Information"),
                  _buildTextField(_nameController, "Full Name", Icons.person_outline),
                  const SizedBox(height: 16),
                  _buildDropdownLabel("User Type", Icons.badge_outlined),
                  _buildUserTypeDropdown(),
                  const SizedBox(height: 16),
                  _buildTextField(_emailController, "Email", Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField(_contactController, "Contact Number", Icons.phone_android_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),
                  _buildTextField(_reasonController, "Reason for Appointment", Icons.chat_bubble_outline, maxLines: 2),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader("Select Counselor & Schedule"),
                  _buildCounselorDropdown(),
                  const SizedBox(height: 16),
                  _buildDatePicker(),
                  
                  const SizedBox(height: 24),
                  const Text("Available Time Slots", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey)),
                  const SizedBox(height: 12),
                  _buildTimeSlots(),

                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Confirm Request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  // --- ANIMATED COMPONENTS ---

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(8, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            height: index == 0 ? 30 : 55,
            width: index == 0 ? 180 : double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ),
    );
  }

  void _showBreathingLoader() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.9),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: DefaultTextStyle(
            style: const TextStyle(decoration: TextDecoration.none),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _BreathingCircle(color: primaryColor),
                const SizedBox(height: 32),
                const Text(
                  "Securing your appointment...",
                  style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- MODERN UI COMPONENTS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: primaryColor)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
      ),
      validator: (val) => val!.isEmpty ? "Required" : null,
    );
  }

  Widget _buildDropdownLabel(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildUserTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: DropdownButtonFormField(
        value: _userType,
        decoration: const InputDecoration(border: InputBorder.none),
        items: ["Student", "Employee"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (val) => setState(() => _userType = val as String),
      ),
    );
  }

  Widget _buildCounselorDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
      child: DropdownButtonFormField<String>(
        hint: const Text("Select Counselor"),
        value: _selectedCounselorId, 
        decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.school_outlined)),
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
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2027));
        if (picked != null) {
          setState(() => _selectedDate = picked);
          _loadSlots();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Text(DateFormat('MMMM dd, yyyy').format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.edit_calendar, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    if (_availableSlots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: const Text("No available slots for this date.", style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableSlots.map((slot) {
        bool isSelected = _selectedSlotId == slot['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedSlotId = slot['id']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!),
              boxShadow: isSelected ? [BoxShadow(color: primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
            ),
            child: Text(
              "${slot['start_time']} - ${slot['end_time']}",
              style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- DIALOGS ---

  void _showBookingSummary(String counselor, dynamic slot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Details", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow(Icons.person, "Counselor", counselor),
            _summaryRow(Icons.calendar_today, "Date", DateFormat('MMMM dd, yyyy').format(_selectedDate)),
            _summaryRow(Icons.access_time, "Time", "${slot['start_time']} - ${slot['end_time']}"),
            const SizedBox(height: 16),
            const Text("A reference code will be generated upon confirmation.", 
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Edit", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () { Navigator.pop(context); _finalSubmit(); },
            child: const Text("Confirm & Book", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: 12),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showSuccess(String ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            const Text("Booking Confirmed!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            const Text("Please save this reference code to track your status.",
                textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: primaryColor.withOpacity(0.2))),
              child: Text(ref, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2, color: primaryColor)),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionIcon(Icons.copy, "Copy", () {
                  Clipboard.setData(ClipboardData(text: ref));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                }),
                const SizedBox(width: 20),
                _actionIcon(Icons.share, "Share", () {
                  Share.share("My Appointment Reference Code: $ref");
                }),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text("Done", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon, color: primaryColor)),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- CUSTOM BREATHING ANIMATION COMPONENT ---

class _BreathingCircle extends StatefulWidget {
  final Color color;
  const _BreathingCircle({required this.color});

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 80 + (25 * _controller.value),
          height: 80 + (25 * _controller.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withOpacity(0.05 + (0.1 * _controller.value)),
            border: Border.all(color: widget.color.withOpacity(0.3), width: 2),
          ),
          child: Center(
            child: Icon(Icons.favorite, color: widget.color, size: 30),
          ),
        );
      },
    );
  }
}