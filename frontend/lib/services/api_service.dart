// lib/services/api_service.dart
//
// This service handles all HTTP communication with the FastAPI backend.
// It provides two methods:
//   - predictUrgency()  -> POST /predict/urgency
//   - predictWaitTime() -> POST /predict/wait-time

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_models.dart';

class ApiService {
  // IMPORTANT: Change this baseUrl depending on where you run the app.
  //
  //   - Android emulator  -> 'http://localhost:8000'
  //   - iOS simulator     -> 'http://localhost:8000'
  //   - Web (Chrome)      -> 'http://localhost:8000'
  //   - Physical phone    -> 'http://<YOUR_PC_LOCAL_IP>:8000'
  //
  // Your PC's local IP can be found in PowerShell with: ipconfig
  static const String baseUrl = 'http://localhost:8000';

  /// Sends the urgency input to the backend and returns the response.
  /// Throws an Exception if the request fails.
  Future<Map<String, dynamic>> predictUrgency(UrgencyInput input) async {
    final url = Uri.parse('$baseUrl/predict/urgency');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  /// Sends the wait-time input to the backend and returns the response.
  /// Throws an Exception if the request fails.
  Future<Map<String, dynamic>> predictWaitTime(WaitTimeInput input) async {
    final url = Uri.parse('$baseUrl/predict/wait-time');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(input.toJson()),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Server returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to backend: $e');
    }
  }

  /// Sends a push notification to a patient via the backend.
  /// Called by staff when they call the next patient.
  Future<void> notifyPatient({
    required String userId,
    required String title,
    required String body,
  }) async {
    final url = Uri.parse('$baseUrl/notify/patient/$userId');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (response.statusCode != 200) {
        throw Exception(
          'Notify failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      // Non-fatal — the notification is a nice-to-have.
      // The Firestore status update already succeeded.
      print('Notify error (non-fatal): $e');
    }
  }
}


