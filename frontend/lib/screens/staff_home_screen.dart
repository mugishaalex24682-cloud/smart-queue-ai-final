// lib/screens/staff_home_screen.dart
//
// Staff dashboard with live stats from Firestore.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'staff_queue_screen.dart';
import 'staff_wait_time_screen.dart';

class StaffHomeScreen extends StatelessWidget {
  final String staffName;

  const StaffHomeScreen({super.key, required this.staffName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('queue')
            .snapshots(),
        builder: (context, snapshot) {
          // Compute stats
          int inQueue = 0;
          int urgent = 0;
          int totalWaitMinutes = 0;
          int waitingCount = 0;

          if (snapshot.hasData) {
            for (final doc in snapshot.data!.docs) {
              final d = doc.data() as Map<String, dynamic>;
              final status = d['status'] ?? 'waiting';
              if (status == 'waiting') {
                inQueue++;
                if (d['urgency'] == 'urgent') urgent++;
                final joined = d['joinedAt'] as Timestamp?;
                if (joined != null) {
                  totalWaitMinutes += DateTime.now()
                      .difference(joined.toDate())
                      .inMinutes
                      .clamp(0, 999);
                  waitingCount++;
                }
              }
            }
          }

          final avgWait = waitingCount > 0
              ? (totalWaitMinutes / waitingCount).round()
              : 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _welcomeCard(),
                const SizedBox(height: 20),

                // ---- Stats ----
                Row(
                  children: [
                    Expanded(
                      child: _statCard('In Queue', '$inQueue',
                          Icons.people, Colors.indigo),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard('Urgent', '$urgent',
                          Icons.priority_high, Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _statCard(
                  'Average Wait',
                  '$avgWait min',
                  Icons.timer,
                  Colors.orange,
                ),

                const SizedBox(height: 24),
                const Text(
                  'Actions',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                _actionCard(
                  icon: Icons.list_alt,
                  title: 'View Queue',
                  subtitle: 'See all patients waiting and their urgency',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StaffQueueScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _actionCard(
                  icon: Icons.hourglass_top,
                  title: 'Predict Wait Time',
                  subtitle: 'Estimate wait time from current queue state',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StaffWaitTimeScreen()),
                  ),
                ),
                const SizedBox(height: 12),
                _actionCard(
                  icon: Icons.analytics,
                  title: 'Reports',
                  subtitle: 'Queue statistics and flow metrics',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Reports will be available shortly.')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome,',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            staffName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Healthcare Worker',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
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
