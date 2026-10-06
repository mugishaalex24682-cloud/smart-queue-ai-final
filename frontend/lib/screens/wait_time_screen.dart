// lib/screens/wait_time_screen.dart
//
// This screen collects queue and service variables,
// sends them to the backend, and displays the predicted waiting time.

import 'package:flutter/material.dart';
import '../models/prediction_models.dart';
import '../services/api_service.dart';

class WaitTimeScreen extends StatefulWidget {
  const WaitTimeScreen({super.key});

  @override
  State<WaitTimeScreen> createState() => _WaitTimeScreenState();
}

class _WaitTimeScreenState extends State<WaitTimeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  // Text controllers for numeric inputs.
  final _patientTypeController = TextEditingController();
  final _utilizationController = TextEditingController();
  final _queueController = TextEditingController();
  final _hourController = TextEditingController();

  // Dropdown value.
  String _resourceUsed = 'Nurses_Type1';

  // State.
  String? _resultText;
  bool _isLoading = false;

  @override
  void dispose() {
    _patientTypeController.dispose();
    _utilizationController.dispose();
    _queueController.dispose();
    _hourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wait Time Prediction'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- Numeric inputs ----------
              _buildIntField('Patient Type (1-4)', _patientTypeController),
              _buildDropdown(
                label: 'Resource Used',
                value: _resourceUsed,
                items: const ['Nurses_Type1', 'Nurses_Type2'],
                onChanged: (v) => setState(() => _resourceUsed = v!),
              ),
              _buildNumberField('Utilization %', _utilizationController),
              _buildIntField('Queue Count Before', _queueController),
              _buildIntField('Hour of Day (0-23)', _hourController),

              const SizedBox(height: 24),

              // ---------- Submit button ----------
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
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
                ),
              ),

              // ---------- Result box ----------
              if (_resultText != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blueGrey),
                  ),
                  child: Text(
                    _resultText!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Helper: a decimal number field.
  Widget _buildNumberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Enter $label';
          if (double.tryParse(value.trim()) == null) return 'Must be a number';
          return null;
        },
      ),
    );
  }

  // Helper: an integer field.
  Widget _buildIntField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Enter $label';
          if (int.tryParse(value.trim()) == null) return 'Must be a whole number';
          return null;
        },
      ),
    );
  }

  // Helper: a dropdown field.
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  // Handle the submit button press.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _resultText = null;
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
        _resultText = 'Predicted Wait:\n$minutes minutes';
      });
    } catch (e) {
      setState(() {
        _resultText = 'Error: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
