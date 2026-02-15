
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = "http://127.0.0.1:8000/api/v1";
  static const String baseUrl = "https://university-counseling-app.onrender.com/api/v1";

  // 1. Submit Assessment Logic
  static Future<Map<String, dynamic>> submitAssessment(String type, List<List<int>> scores) async {
    final response = await http.post(
      Uri.parse("$baseUrl/assessment/submit"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_type": type, "scores": scores}),
    );
    return jsonDecode(response.body);
  }

  // 2. Book Appointment Logic
  static Future<Map<String, dynamic>> bookAppointment({
    required String name,
    required String type,
    required String email,
    required String contact,
    required String reason,
    required String counselorId,
    required String timeslotId,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/appointment/book"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": name,
        "user_type": type,
        "email": email,
        "contact": contact,
        "reason": reason,
        "counselor_id": counselorId,
        "timeslot_id": timeslotId,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to book appointment: ${response.body}");
    }
  }

  // 3. Admin Login with Token Support
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // Save to Persistent Storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', data['token']);
      await prefs.setString('admin_data', jsonEncode(data['user']));
      
      return data;
    } else {
      throw Exception("Unauthorized Access");
    }
  }

  static Future<Map<String, dynamic>> getStressStats() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/stats/stress"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load statistics");
    }
  }

  // Fetch slots for a specific date
  static Future<List<dynamic>> getSlotsByDate(String counselorId, String date) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/slots?counselor_id=$counselorId&date=$date"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load slots");
    }
  }

  // Delete a specific slot
  static Future<Map<String, dynamic>> deleteSlot(String slotId) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/admin/slots/$slotId"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to delete slot");
    }
  }

  // Create Manual Slot with Start and End times
  static Future<Map<String, dynamic>> createManualSlot(
      String cId, String date, String startTime, String endTime) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/slots/manual"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "c_id": cId,
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create slot: ${response.body}");
    }
  }

  // Add this inside your ApiService class in api_service.dart
  static Future<Map<String, dynamic>> checkAppointmentStatus(String refCode) async {
    final response = await http.get(
      Uri.parse("$baseUrl/appointment/status/$refCode"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // This triggers the 'catch' block in your landing page
      throw Exception("Reference code not found");
    }
  }

   static Future<List<dynamic>> getAllCounselors() async {
    // REMOVE the extra "/api/v1" since it's already in your baseUrl
    final response = await http.get(Uri.parse("$baseUrl/counselors")); 
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load counselors: ${response.statusCode}");
    }
  }

  static Future<void> cancelAppointment(String refCode) async {
    final response = await http.post(
      Uri.parse("$baseUrl/appointment/cancel/$refCode"),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to cancel appointment");
    }
  }
  // Fetch all appointments for the admin to manage
  static Future<List<dynamic>> getAllAppointments() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/appointments/all"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load appointments");
    }
  }

  // Update status (Confirm/Reject)
  static Future<Map<String, dynamic>> updateAppointmentStatus(
      String id, 
      String status, 
      {String? notes} // Add this optional named parameter
  ) async {
    // Use Uri.encodeComponent to safely handle spaces in the notes
    final url = "$baseUrl/admin/appointments/decision?appointment_id=$id&new_status=$status&notes=${Uri.encodeComponent(notes ?? '')}";
    
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update status: ${response.body}");
    }
  }
}