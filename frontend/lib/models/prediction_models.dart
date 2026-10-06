// lib/models/prediction_models.dart
//
// This file defines the data models used to send data to the API.
// It contains two classes: UrgencyInput and WaitTimeInput.
// Each class has a `toJson()` method that converts the object to a Map,
// which is what the HTTP request body needs.

/// Input data for the urgency prediction API.
class UrgencyInput {
  final double temperature;
  final double heartrate;
  final double resprate;
  final double o2sat;
  final double sbp;
  final double dbp;
  final double pain;
  final String gender;
  final String race;
  final String arrivalTransport;

  UrgencyInput({
    required this.temperature,
    required this.heartrate,
    required this.resprate,
    required this.o2sat,
    required this.sbp,
    required this.dbp,
    required this.pain,
    required this.gender,
    required this.race,
    required this.arrivalTransport,
  });

  /// Convert the object to a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'heartrate': heartrate,
      'resprate': resprate,
      'o2sat': o2sat,
      'sbp': sbp,
      'dbp': dbp,
      'pain': pain,
      'gender': gender,
      'race': race,
      'arrival_transport': arrivalTransport,
    };
  }
}

/// Input data for the waiting-time prediction API.
class WaitTimeInput {
  final int patientType;
  final String resourceUsed;
  final double utilizationPercent;
  final int queueCountBefore;
  final int hour;

  WaitTimeInput({
    required this.patientType,
    required this.resourceUsed,
    required this.utilizationPercent,
    required this.queueCountBefore,
    required this.hour,
  });

  /// Convert the object to a JSON-compatible Map.
  Map<String, dynamic> toJson() {
    return {
      'Patient_Type': patientType,
      'Resourse_Used': resourceUsed,
      'Utilization_Percent': utilizationPercent,
      'Queue_Count_Before_Processing': queueCountBefore,
      'hour': hour,
    };
  }
}
