// lib/models/appointment_store.dart
//
// A simple in-memory store for booked appointments.
// This lets the booking screen and the "My Appointments" screen
// share data without a backend.
//
// When the real backend is added, this store will be replaced by
// API calls (POST /appointments, GET /appointments).

class Appointment {
  final String department;
  final String doctor;
  final String date;    // YYYY-MM-DD
  final String timeSlot; // e.g. "09:00 AM"
  final String reason;

  Appointment({
    required this.department,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    required this.reason,
  });
}

class AppointmentStore {
  // In-memory list. Shared across the whole app during a session.
  static final List<Appointment> _appointments = [];

  /// All appointments, newest first.
  static List<Appointment> get all =>
      List.unmodifiable(_appointments.reversed);

  /// Add a new appointment.
  static void add(Appointment appointment) {
    _appointments.add(appointment);
  }

  /// Remove an appointment by index (from the reversed list).
  static void removeAt(int reversedIndex) {
    final actualIndex = _appointments.length - 1 - reversedIndex;
    if (actualIndex >= 0 && actualIndex < _appointments.length) {
      _appointments.removeAt(actualIndex);
    }
  }

  /// Number of stored appointments.
  static int get count => _appointments.length;
}
