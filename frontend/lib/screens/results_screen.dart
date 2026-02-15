import 'package:flutter/material.dart';
import '../models/assessment_result.dart';
import 'assessment_screen.dart';
import 'booking_screen.dart';

class ResultsScreen extends StatelessWidget {
  final AssessmentResult result;

  const ResultsScreen({super.key, required this.result});

  // Updated Recommendation Logic for 3 Tiers
  String _getRecommendation() {
    if (result.level == "High") {
      return "Immediate Action Recommended: Your scores indicate a high level of distress. We strongly encourage you to book an appointment with a counselor to talk things through.";
    } else if (result.level == "Moderate") {
      return "Proactive Support Recommended: You seem to be experiencing some challenges. It might be helpful to schedule a session to discuss coping strategies and stress management.";
    } else {
      return "Maintain Wellness: You are doing well! Continue practicing self-care. If you ever feel overwhelmed, our doors are always open.";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic Color Logic
    Color resultColor;
    String statusText;

    if (result.level == "High") {
      resultColor = Colors.redAccent;
      statusText = "HIGH STRESS LEVEL";
    } else if (result.level == "Moderate") {
      resultColor = Colors.orange;
      statusText = "MODERATE STRESS LEVEL";
    } else {
      resultColor = Colors.green;
      statusText = "GOOD STANDING";
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Assessment Result"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: resultColor, width: 8),
              ),
              child: Column(
                children: [
                  Text(
                    result.finalScore.toStringAsFixed(1),
                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: resultColor),
                  ),
                  const Text("AVG SCORE", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              statusText,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: resultColor),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: resultColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: resultColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text("Recommendation:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(_getRecommendation(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
            const Spacer(),
            
            // Show booking button for both High and Moderate
            if (result.triggerWarning)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Matches your UI
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
              onPressed: () {
                // FIXED: Added navigation to the Booking Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BookingScreen()),
                );
              },
              child: const Text(
                "Book an Appointment",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AssessmentScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: BorderSide(color: resultColor),
              ),
              child: Text("Retake Assessment", style: TextStyle(color: resultColor)),
            ),

            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}