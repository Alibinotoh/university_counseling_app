import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import 'components/analytics_module.dart';
import 'components/schedule_module.dart';
import 'components/appointment_module.dart';
import 'components/profile_module.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic> adminData;
  const AdminDashboard({super.key, required this.adminData});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>> _statsFuture;

  // --- Theme Constants ---
  final Color msuMaroon = const Color(0xFF800020);
  final Color darkSlate = const Color(0xFF1E293B);      
  final Color scaffoldBg = const Color(0xFFF1F5F9);     
  final Color surfaceColor = Colors.white;
  final Color colorEmerald = const Color(0xFF10B981);
  final Color colorSlateText = const Color(0xFF64748B);

  // --- Schedule State ---
  DateTime _viewDate = DateTime.now();
  List<dynamic> _dailySlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _statsFuture = ApiService.getStressStats();
    _fetchDailySlots();
  }

  // --- Logic Handlers ---
  void _refreshStats() {
    setState(() {
      _statsFuture = ApiService.getStressStats();
    });
  }

  Future<void> _fetchDailySlots() async {
    if (!mounted) return;
    setState(() => _isLoadingSlots = true);
    try {
      final String? adminId = widget.adminData['id']?.toString();
      if (adminId == null) return;
      final dateStr = DateFormat('yyyy-MM-dd').format(_viewDate);
      final slots = await ApiService.getSlotsByDate(adminId, dateStr);
      if (mounted) setState(() => _dailySlots = slots);
    } catch (e) {
      debugPrint("Slot Fetch Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingSlots = false);
    }
  }

  void _deleteSlot(String id) async {
    await ApiService.deleteSlot(id);
    _fetchDailySlots();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 900;
        bool isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;

        return Scaffold(
          backgroundColor: scaffoldBg,
          bottomNavigationBar: !isDesktop && !isTablet ? _buildBottomNav() : null,
          body: Row(
            children: [
              if (isDesktop || isTablet) _buildSideNav(isDesktop),
              Expanded(
                child: Column(
                  children: [
                    _buildHeader(constraints.maxWidth),
                    Expanded(child: _buildBody(constraints.maxWidth)),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: _selectedIndex == 1 ? _buildFab() : null,
        );
      },
    );
  }

  // --- Navigation Components ---
  Widget _buildSideNav(bool isExtended) {
    return NavigationRail(
      backgroundColor: darkSlate,
      extended: isExtended,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      leading: Padding(
        padding: const EdgeInsets.all(20),
        child: CircleAvatar(backgroundColor: msuMaroon, child: const Icon(Icons.admin_panel_settings, color: Colors.white)),
      ),
      unselectedIconTheme: const IconThemeData(color: Colors.white60),
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedLabelTextStyle: const TextStyle(color: Colors.white60),
      selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.grid_view_rounded), label: Text("Dashboard")),
        NavigationRailDestination(icon: Icon(Icons.calendar_today_rounded), label: Text("Schedule")),
        NavigationRailDestination(icon: Icon(Icons.assignment_ind_rounded), label: Text("Appointments")),
        NavigationRailDestination(icon: Icon(Icons.manage_accounts_rounded), label: Text("Account")),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: msuMaroon,
      unselectedItemColor: colorSlateText,
      onTap: (i) => setState(() => _selectedIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: "Stats"),
        BottomNavigationBarItem(icon: Icon(Icons.event_note_rounded), label: "Slots"),
        BottomNavigationBarItem(icon: Icon(Icons.approval_rounded), label: "Appts"),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }

  Widget _buildHeader(double width) {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Back,", style: TextStyle(color: colorSlateText, fontSize: 12, fontWeight: FontWeight.w600)),
                Text(widget.adminData['name'] ?? "Counselor", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              ],
            ),
          ),
          if (width > 500)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: scaffoldBg, borderRadius: BorderRadius.circular(10)),
              child: Text(DateFormat('EEE, MMM d').format(DateTime.now()), style: TextStyle(fontWeight: FontWeight.bold, color: darkSlate)),
            ),
        ],
      ),
    );
  }

  // --- Dynamic Body Switcher ---
  Widget _buildBody(double width) {
    switch (_selectedIndex) {
      case 0:
        return AnalyticsModule(
          statsFuture: _statsFuture,
          onRefresh: _refreshStats,
          width: width,
          msuMaroon: msuMaroon,
          colorEmerald: colorEmerald,
          colorSlateText: colorSlateText,
          surfaceColor: surfaceColor,
        );
      case 1:
        return ScheduleModule(
          viewDate: _viewDate,
          dailySlots: _dailySlots,
          isLoading: _isLoadingSlots,
          width: width,
          msuMaroon: msuMaroon,
          colorEmerald: colorEmerald,
          surfaceColor: surfaceColor,
          onDateChanged: (newDate) {
            setState(() => _viewDate = newDate);
            _fetchDailySlots();
          },
          onDeleteSlot: _deleteSlot,
          onBulkGenerate: _showBulkGenerateDialog, // MODIFIED: Connected bulk logic
          onClearAll: _handleClearAll, // Add this line
        );
      case 2:
        return AppointmentModule(
          width: width,
          msuMaroon: msuMaroon,
          colorEmerald: colorEmerald,
          darkSlate: darkSlate,
          surfaceColor: surfaceColor,
        );
      case 3:
        return ProfileModule(
          adminData: widget.adminData,
          msuMaroon: msuMaroon,
          surfaceColor: surfaceColor,
          colorSlateText: colorSlateText,
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildFab() {
    return FloatingActionButton.extended(
      backgroundColor: msuMaroon,
      onPressed: _showCreateSlotDialog,
      label: const Text("New Slot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add, color: Colors.white),
    );
  }

  // --- Dialogs ---

  void _showBulkGenerateDialog() {
    TimeOfDay start = const TimeOfDay(hour: 8, minute: 0);
    TimeOfDay end = const TimeOfDay(hour: 17, minute: 0);
    int duration = 60;

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: const Text("Bulk Generate Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Start: ${start.format(c)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final t = await showTimePicker(context: c, initialTime: start);
                  if (t != null) setS(() => start = t);
                },
              ),
              ListTile(
                title: Text("End: ${end.format(c)}"),
                trailing: const Icon(Icons.access_time_filled),
                onTap: () async {
                  final t = await showTimePicker(context: c, initialTime: end);
                  if (t != null) setS(() => end = t);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: duration,
                decoration: const InputDecoration(
                  labelText: "Slot Duration",
                  border: OutlineInputBorder(),
                ),
                items: [30, 45, 60, 90].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text("$value Minutes"),
                  );
                }).toList(),
                onChanged: (v) => setS(() => duration = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: msuMaroon),
              onPressed: () async {
                // 1. Show a non-dismissible loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );

                try {
                  await ApiService.generateBulkSlots(
                    counselorId: widget.adminData['id'].toString(),
                    date: DateFormat('yyyy-MM-dd').format(_viewDate),
                    startTime: start.format(c),
                    endTime: end.format(c),
                    slotDurationMinutes: duration,
                  );
                  
                  // 2. Pop the Loading Indicator
                  if (mounted) Navigator.of(context).pop(); 
                  // 3. Pop the Bulk Settings Dialog
                  if (mounted) Navigator.pop(c); 
                  
                  _fetchDailySlots(); // Refresh the grid
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Schedule generated successfully!")),
                  );
                } catch (e) {
                  if (mounted) Navigator.of(context).pop(); // Pop loading
                  debugPrint("Bulk Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: const Text("Generate Day", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateSlotDialog() {
    TimeOfDay? start, end;
    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(builder: (c, setS) => AlertDialog(
        title: const Text("Create Manual Slot", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(start?.format(c) ?? "Start Time"),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final t = await showTimePicker(context: c, initialTime: TimeOfDay.now());
                if (t != null) setS(() => start = t);
              },
            ),
            ListTile(
              title: Text(end?.format(c) ?? "End Time"),
              trailing: const Icon(Icons.access_time_filled),
              onTap: () async {
                final t = await showTimePicker(context: c, initialTime: TimeOfDay.now());
                if (t != null) setS(() => end = t);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: msuMaroon),
            onPressed: (start != null && end != null) ? () async {
              try {
                await ApiService.createManualSlot(
                  widget.adminData['id'].toString(), 
                  DateFormat('yyyy-MM-dd').format(_viewDate), 
                  start!.format(c), 
                  end!.format(c)
                );
                if (c.mounted) Navigator.pop(c); 
                _fetchDailySlots();
              } catch (e) {
                debugPrint("Error creating slot: $e");
              }
            } : null,
            child: const Text("Create", style: TextStyle(color: Colors.white)),
          )
        ],
      )),
    );
  }

  void _handleClearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Clear Daily Schedule?"),
        // Updated text to reflect safety logic
        content: Text(
          "This will delete all AVAILABLE slots for ${DateFormat('MMMM dd').format(_viewDate)}.\n\n"
          "Note: Booked appointments will NOT be deleted."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false), 
            child: const Text("Cancel")
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true), 
            child: const Text("Clear Available", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final id = widget.adminData['id'].toString();
        final date = DateFormat('yyyy-MM-dd').format(_viewDate);
        
        final response = await ApiService.clearAllSlots(id, date);
        
        print("--- DEBUG: Server Response: $response ---"); 
        
        // Small delay to allow DB to settle before refresh
        await Future.delayed(const Duration(milliseconds: 300)); 
        _fetchDailySlots();
        
        if (mounted) {
          final count = response['deleted_count'] ?? 0;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    count > 0 ? Icons.check_circle : Icons.info_outline, 
                    color: Colors.white
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(count > 0 
                      ? "Cleared $count available slots. Booked slots were preserved." 
                      : "No available slots to clear for this date."),
                  ),
                ],
              ),
              backgroundColor: count > 0 ? colorEmerald : Colors.orange[800],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint("Clear Error: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to clear slots. Please check your connection."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }
}