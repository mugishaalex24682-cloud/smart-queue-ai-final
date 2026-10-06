// lib/screens/patient_home_screen.dart
//
// Patient dashboard. Reads the live queue from Firestore and shows
// the patient's real position and estimated wait time.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'urgency_screen.dart';
import 'appointment_booking_screen.dart';
import 'my_appointments_screen.dart';
import 'profile_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  final String patientName;
  final String patientPhone;

  const PatientHomeScreen({
    super.key,
    required this.patientName,
    required this.patientPhone,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(
                    patientName: patientName,
                    patientPhone: patientPhone,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not logged in'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _welcomeCard(),
                  const SizedBox(height: 20),
                  _queueCard(context, user.uid),
                  const SizedBox(height: 24),
                  _actionsGrid(context),
                ],
              ),
            ),
    );
  }

  // ---- Welcome card ----
  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome,',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            patientName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (patientPhone.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              patientPhone,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Live queue card using StreamBuilder ----
  Widget _queueCard(BuildContext context, String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('queue')
          .where('status', whereIn: ['waiting', 'called'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDecoration(),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Text('Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }

        final all = snapshot.data?.docs ?? [];

        // Sort: urgent first, then by joinedAt (oldest first)
        final sorted = [...all];
        sorted.sort((a, b) {
          final am = a.data() as Map<String, dynamic>;
          final bm = b.data() as Map<String, dynamic>;
          final aUrg = am['urgency'] == 'urgent' ? 1 : 0;
          final bUrg = bm['urgency'] == 'urgent' ? 1 : 0;
          if (aUrg != bUrg) return bUrg - aUrg; // urgent first
          final aTime = am['joinedAt'] as Timestamp?;
          final bTime = bm['joinedAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return aTime.compareTo(bTime); // oldest first
        });

        // Find this user's entry
        final myDoc = sorted.firstWhere(
          (d) => (d.data() as Map<String, dynamic>)['userId'] == userId,
          orElse: () => sorted.isNotEmpty ? sorted.first : sorted.first,
        );

        // Is the user actually in the queue?
        final inQueue = all.any(
          (d) => (d.data() as Map<String, dynamic>)['userId'] == userId,
        );

        if (!inQueue) {
          return _notInQueueCard();
        }

        // Compute position and status
        final myData = myDoc.data() as Map<String, dynamic>;
        final myIndex =
            sorted.indexWhere((d) => (d.data() as Map<String, dynamic>)['userId'] == userId);
        final position = myIndex + 1;
        final status = myData['status'] ?? 'waiting';
        final urgency = myData['urgency'] ?? 'not_urgent';

        // Simple estimated wait: ~4 minutes per patient ahead
        final estWait = (position - 1) * 4;

        return _inQueueCard(position, status, urgency, estWait);
      },
    );
  }

  Widget _notInQueueCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.hourglass_empty, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Not in queue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap "Join Queue" below to enter the waiting line.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _inQueueCard(
      int position, String status, String urgency, int estWait) {
    final isCalled = status == 'called';
    final isUrgent = urgency == 'urgent';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCalled ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCalled ? Border.all(color: Colors.green, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCalled ? Icons.check_circle : Icons.hourglass_top,
                color: isCalled ? Colors.green : Colors.teal,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCalled ? "It's your turn!" : 'You are in the queue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isCalled ? Colors.green.shade800 : Colors.black,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUrgent
                      ? Colors.red.withOpacity(0.12)
                      : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isUrgent ? 'URGENT' : 'Normal',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statBlock('Position', '#$position', Icons.people),
              _statBlock('Est. Wait', '$estWait min', Icons.timer),
            ],
          ),
          if (isCalled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Please proceed to the triage desk now.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Text(
              'Please wait in the waiting area. You will be notified when it is your turn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // ---- Actions: Join Queue, Book Appointment, My Appointments ----
  Widget _actionsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Join Queue', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UrgencyScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.calendar_month),
            label:
                const Text('Book Appointment', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AppointmentBookingScreen()),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.list_alt),
            label:
                const Text('My Appointments', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              side: const BorderSide(color: Colors.teal, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyAppointmentsScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _statBlock(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.teal),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You will need to log in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
