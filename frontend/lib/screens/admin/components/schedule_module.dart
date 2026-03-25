import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleModule extends StatelessWidget {
  final DateTime viewDate;
  final List<dynamic> dailySlots;
  final bool isLoading;
  final double width;
  final Color msuMaroon;
  final Color colorEmerald;
  final Color surfaceColor;
  final Function(DateTime) onDateChanged;
  final Function(String) onDeleteSlot;
  final VoidCallback onBulkGenerate; 
  final VoidCallback onClearAll; // Add this

  const ScheduleModule({
    super.key,
    required this.viewDate,
    required this.dailySlots,
    required this.isLoading,
    required this.width,
    required this.msuMaroon,
    required this.colorEmerald,
    required this.surfaceColor,
    required this.onDateChanged,
    required this.onDeleteSlot,
    required this.onBulkGenerate, // Added to constructor
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _calendarHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : _slotGrid()
          ),
        ],
      ),
    );
  }

  Widget _calendarHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor, 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Navigation
          IconButton(
            onPressed: () => onDateChanged(viewDate.subtract(const Duration(days: 1))), 
            icon: const Icon(Icons.chevron_left)
          ),
          
          // Date Display
          Expanded(
            child: Center(
              child: Text(
                DateFormat('MMMM dd, yyyy').format(viewDate), 
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)
              ),
            ),
          ),

          // Tools Group
          Row(
            children: [
              // --- BULK GENERATE BUTTON ---
              IconButton(
                onPressed: onBulkGenerate,
                icon: const Icon(Icons.auto_fix_high, color: Colors.blueAccent),
                tooltip: "Bulk Generate Slots",
              ),

              const SizedBox(width: 8),
              IconButton(
                onPressed: onClearAll,
                icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
                tooltip: "Clear All Slots",
              ),
              const SizedBox(width: 8),
              // Date Picker
              IconButton(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: context, 
                    initialDate: viewDate, 
                    firstDate: DateTime(2024), 
                    lastDate: DateTime(2030)
                  );
                  if (d != null) onDateChanged(d);
                },
                icon: Icon(Icons.calendar_month, color: msuMaroon),
              ),
              // Right Navigation
              IconButton(
                onPressed: () => onDateChanged(viewDate.add(const Duration(days: 1))), 
                icon: const Icon(Icons.chevron_right)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _slotGrid() {
    if (dailySlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              "No time slots configured for this day.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width < 700 ? 1 : 2,
        mainAxisExtent: 80,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: dailySlots.length,
      itemBuilder: (context, i) {
        final slot = dailySlots[i];
        bool isAvail = slot['is_available'] ?? true;
        
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor, 
            borderRadius: BorderRadius.circular(12), 
            border: Border.all(
              color: isAvail ? colorEmerald.withOpacity(0.2) : Colors.red.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: ListTile(
            leading: Icon(
              isAvail ? Icons.check_circle : Icons.lock_clock, 
              color: isAvail ? colorEmerald : Colors.red, 
              size: 20
            ),
            title: Text(
              "${slot['start_time']} - ${slot['end_time']}", 
              style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            subtitle: Text(
              isAvail ? "Open for booking" : "Reserved/Booked", 
              style: TextStyle(
                fontSize: 11, 
                color: isAvail ? colorEmerald : Colors.red[700],
                fontWeight: FontWeight.w600
              )
            ),
            trailing: isAvail 
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.blueGrey), 
                  onPressed: () => onDeleteSlot(slot['id'].toString())
                ) 
              : null,
          ),
        );
      },
    );
  }
}