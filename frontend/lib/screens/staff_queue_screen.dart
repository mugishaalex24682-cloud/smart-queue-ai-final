// lib/screens/staff_queue_screen.dart
//
// Staff queue view. Reads waiting patients from Firestore in real time.
// Call Next updates the patient's status to 'called'.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';

class StaffQueueScreen extends StatelessWidget {
  const StaffQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Queue'),
        backgroundColor: Colors.indigo,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('queue')
            .where('status', isEqualTo: 'waiting')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          // Sort: urgent first, then by joinedAt (oldest first)
          final sorted = [...docs];
          sorted.sort((a, b) {
            final am = a.data() as Map<String, dynamic>;
            final bm = b.data() as Map<String, dynamic>;
            final aUrg = am['urgency'] == 'urgent' ? 1 : 0;
            final bUrg = bm['urgency'] == 'urgent' ? 1 : 0;
            if (aUrg != bUrg) return bUrg - aUrg;
            final aTime = am['joinedAt'] as Timestamp?;
            final bTime = bm['joinedAt'] as Timestamp?;
            if (aTime == null || bTime == null) return 0;
            return aTime.compareTo(bTime);
          });

          return Column(
            children: [
              // ---- Call Next button ----
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.campaign),
                    label: const Text(
                      'Call Next Patient',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _callNext(context, sorted.first),
                  ),
                ),
              ),
              const Divider(height: 1),

              // ---- Queue list ----
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildPatientCard(context, sorted[index], index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Queue is empty',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'All patients have been served.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(
      BuildContext context, QueryDocumentSnapshot doc, int index) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['patientName'] ?? 'Unknown';
    final complaint = data['complaint'] ?? '';
    final urgency = data['urgency'] ?? 'not_urgent';
    final isUrgent = urgency == 'urgent';
    final joinedAt = data['joinedAt'] as Timestamp?;

    // Compute wait time so far
    int waitMinutes = 0;
    if (joinedAt != null) {
      waitMinutes =
          DateTime.now().difference(joinedAt.toDate()).inMinutes.clamp(0, 999);
    }

    final urgentColor = isUrgent ? Colors.red : Colors.green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: urgentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isUrgent ? 'URGENT' : 'Normal',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: urgentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  complaint.isEmpty ? '(no complaint)' : complaint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '$waitMinutes min',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      doc.id.substring(0, 8),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _callNext(
      BuildContext context, QueryDocumentSnapshot nextDoc) async {
    final data = nextDoc.data() as Map<String, dynamic>;
    final name = data['patientName'] ?? 'Unknown';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Call next patient?'),
        content: Text(
          'Name: $name\n'
          'Urgency: ${data['urgency'] == 'urgent' ? 'URGENT' : 'Not urgent'}\n'
          'Complaint: ${data['complaint'] ?? '(none)'}\n\n'
          'The patient will be marked as called.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Call now'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('queue')
          .doc(nextDoc.id)
          .update({
        'status': 'called',
        'calledAt': FieldValue.serverTimestamp(),
      });

      // Send FCM push to the patient
      final userId = data['userId'] as String?;
      if (userId != null) {
        final api = ApiService();
        await api.notifyPatient(
          userId: userId,
          title: "It's your turn!",
          body: 'Please proceed to the triage desk now.',
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name called')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

