import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // --- AUTOMATIC URL SWITCHING ---
  // When you run 'flutter run', it uses localhost.
  // When you run 'flutter build web' and deploy to Render, it uses the live URL.
  static String get baseUrl {
    if (kDebugMode) {
      return "http://127.0.0.1:8000/api/v1";
    } else {
      return "https://university-counseling-app.onrender.com/api/v1";
    }
  }
  // --- MODIFIED: GETS ALL TREND DATA (HIGH, MOD, LOW) ---
  static Future<Map<String, dynamic>> getStressStats() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/admin/stats/stress"));
      
      if (response.statusCode == 200) {
        // We return the full body so Dashboard can see all trend keys
        return jsonDecode(response.body);
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error (getStressStats): $e");
      // Return safe defaults to prevent UI crashes if the API is down
      return {
        'High': 0, 
        'Moderate': 0, 
        'Low': 0,
        'trend_high': [],
        'trend_mod': [],
        'trend_low': []
      };
    }
  }

  // --- SUBMIT ASSESSMENT (Modified to include userName) ---
  static Future<Map<String, dynamic>> submitAssessment(String userName, List<List<int>> scores) async {
    final response = await http.post(
      Uri.parse("$baseUrl/assessment/submit"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_name": userName, // This matches your Pydantic model
        "user_type": "User",    // Generalized type
        "scores": scores
      }),
    );
    return jsonDecode(response.body);
  }

  // --- BOOK APPOINTMENT ---
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

  // --- ADMIN LOGIN ---
  static Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', data['token']);
      await prefs.setString('admin_data', jsonEncode(data['user']));
      return data;
    } else {
      throw Exception("Unauthorized Access");
    }
  }

  // --- SLOTS MANAGEMENT ---
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

  // --- APPOINTMENT STATUS & CANCEL ---
  static Future<Map<String, dynamic>> checkAppointmentStatus(String refCode) async {
    final response = await http.get(Uri.parse("$baseUrl/appointment/status/$refCode"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Reference code not found");
    }
  }

  static Future<void> cancelAppointment(String refCode) async {
    final response = await http.post(Uri.parse("$baseUrl/appointment/cancel/$refCode"));
    if (response.statusCode != 200) throw Exception("Failed to cancel appointment");
  }

  // --- COUNSELORS & APPOINTMENTS MGMT ---
  static Future<List<dynamic>> getAllCounselors() async {
    final response = await http.get(Uri.parse("$baseUrl/counselors")); 
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load counselors");
    }
  }

  static Future<List<dynamic>> getAllAppointments() async {
    final response = await http.get(Uri.parse("$baseUrl/admin/appointments/all"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load appointments");
    }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(
        String id, String status, {String? notes}) async {
      final url = "$baseUrl/admin/appointments/decision?appointment_id=$id&new_status=$status&notes=${Uri.encodeComponent(notes ?? '')}";
      final response = await http.post(Uri.parse(url));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to update status");
      }
    }

    static Future<Map<String, dynamic>> generateBulkSlots({
    required String counselorId,
    required String date,
    required String startTime,
    required String endTime,
    required int slotDurationMinutes,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/admin/slots/bulk"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "counselor_id": counselorId,
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
        "slot_duration": slotDurationMinutes,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to generate bulk slots: ${response.body}");
    }
  }

  // Change return type from Future<void> to Future<Map<String, dynamic>>
  static Future<Map<String, dynamic>> clearAllSlots(String counselorId, String date) async {
    final url = Uri.parse("$baseUrl/admin/slots/clear").replace(
      queryParameters: {
        'counselor_id': counselorId.trim(),
        'date': date.trim(),
      },
    );

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      // Decode and return the JSON (containing deleted_count)
      return jsonDecode(response.body); 
    } else {
      throw Exception("Failed to clear slots: ${response.body}");
    }
  }

  static Future<List<dynamic>> getAssessmentLogs() async {
    final response = await http.get(Uri.parse('$baseUrl/admin/assessment-logs'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load logs");
    }
  }
}