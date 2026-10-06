// lib/screens/home_screen.dart
//
// This is the home screen of the app.
// It shows two buttons:
//   1. Check Urgency     -> navigates to UrgencyScreen
//   2. Predict Wait Time -> navigates to WaitTimeScreen

import 'package:flutter/material.dart';
import 'urgency_screen.dart';
import 'wait_time_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Queue AI'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo / icon
              const Icon(Icons.local_hospital, size: 80, color: Colors.teal),
              const SizedBox(height: 16),

              // Title
              const Text(
                'AI-Assisted Hospital Queue',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Decision support for triage and patient flow',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Button 1 — Urgency classifier
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.priority_high),
                  label: const Text('Check Urgency', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
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

              // Button 2 — Waiting time predictor
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.timer),
                  label: const Text('Predict Wait Time', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WaitTimeScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
