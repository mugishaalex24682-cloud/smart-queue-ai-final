// lib/screens/staff_wait_time_screen.dart
//
// Staff tool: predict waiting time using the trained regression model
// via the FastAPI backend.

import 'package:flutter/material.dart';
import '../models/prediction_models.dart';
import '../services/api_service.dart';

class StaffWaitTimeScreen extends StatefulWidget {
  const StaffWaitTimeScreen({super.key});

  @override
  State<StaffWaitTimeScreen> createState() => _StaffWaitTimeScreenState();
}

class _StaffWaitTimeScreenState extends State<StaffWaitTimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _patientTypeController = TextEditingController(text: '1');
  final _utilizationController = TextEditingController(text: '16.67');
  final _queueController = TextEditingController(text: '5');
  final _hourController = TextEditingController(text: '9');

  String _resourceUsed = 'Nurses_Type1';
  bool _isLoading = false;
  String? _resultText;
  bool _isError = false;

  @override
  void dispose() {
    _patientTypeController.dispose();
    _utilizationController.dispose();
    _queueController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _resultText = null;
      _isError = false;
    });

    final input = WaitTimeInput(
      patientType: int.parse(_patientTypeController.text.trim()),
      resourceUsed: _resourceUsed,
      utilizationPercent: double.parse(_utilizationController.text.trim()),
      queueCountBefore: int.parse(_queueController.text.trim()),
      hour: int.parse(_hourController.text.trim()),
    );

    try {
      final result = await _apiService.predictWaitTime(input);
      final minutes = result['predicted_wait_time_minutes'] ?? 0.0;
      setState(() {
        _resultText = 'Predicted wait: $minutes minutes';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
        _isError = true;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Predict Wait Time'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---- Header card ----
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top,
                        color: Colors.indigo, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Estimate the waiting time for the current '
                        'queue state using the trained regression model.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- Patient Type ----
              TextFormField(
                controller: _patientTypeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Patient Type (1-4)',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter patient type';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 4) return 'Must be 1, 2, 3, or 4';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Resource Used ----
              DropdownButtonFormField<String>(
                initialValue: _resourceUsed,
                items: const [
                  DropdownMenuItem(value: 'Nurses_Type1', child: Text('Nurses_Type1')),
                  DropdownMenuItem(value: 'Nurses_Type2', child: Text('Nurses_Type2')),
                ],
                onChanged: (v) => setState(() => _resourceUsed = v!),
                decoration: const InputDecoration(
                  labelText: 'Resource Used',
                  prefixIcon: Icon(Icons.medical_services_outlined),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // ---- Utilization % ----
              TextFormField(
                controller: _utilizationController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Utilization %',
                  prefixIcon: Icon(Icons.speed),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter utilization';
                  final n = double.tryParse(v.trim());
                  if (n == null || n < 0 || n > 100) return 'Must be 0-100';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Queue Count Before ----
              TextFormField(
                controller: _queueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Queue Count Before Processing',
                  prefixIcon: Icon(Icons.people_outline),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter queue count';
                  if (int.tryParse(v.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ---- Hour ----
              TextFormField(
                controller: _hourController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hour of Day (0-23)',
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter hour';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 0 || n > 23) return 'Must be 0-23';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ---- Predict button ----
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_graph),
                  label: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Predict Wait Time',
                          style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _predict,
                ),
              ),

              // ---- Result box ----
              if (_resultText != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isError
                        ? Colors.red.shade50
                        : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isError
                          ? Colors.red.shade200
                          : Colors.indigo.shade200,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _isError
                            ? Icons.error_outline
                            : Icons.check_circle_outline,
                        color: _isError ? Colors.red : Colors.indigo,
                        size: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _resultText!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
