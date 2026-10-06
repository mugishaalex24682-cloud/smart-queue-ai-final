// lib/screens/urgency_screen.dart
//
// Symptom entry with plain-English labels for patients.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prediction_models.dart';
import '../services/api_service.dart';

class UrgencyScreen extends StatefulWidget {
  const UrgencyScreen({super.key});

  @override
  State<UrgencyScreen> createState() => _UrgencyScreenState();
}

class _UrgencyScreenState extends State<UrgencyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  final _tempController = TextEditingController(text: '98.6');
  final _hrController = TextEditingController(text: '88');
  final _rrController = TextEditingController(text: '18');
  final _o2Controller = TextEditingController(text: '97');
  final _sbpController = TextEditingController(text: '120');
  final _dbpController = TextEditingController(text: '80');
  final _painController = TextEditingController(text: '3');
  final _complaintController = TextEditingController();

  String _gender = 'F';
  String _race = 'WHITE';
  String _transport = 'WALK IN';

  bool _isLoading = false;
  String? _resultText;
  bool _isError = false;

  @override
  void dispose() {
    _tempController.dispose();
    _hrController.dispose();
    _rrController.dispose();
    _o2Controller.dispose();
    _sbpController.dispose();
    _dbpController.dispose();
    _painController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _resultText = null;
      _isError = false;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Please log in first.');
      }

      final input = UrgencyInput(
        temperature: double.parse(_tempController.text.trim()),
        heartrate: double.parse(_hrController.text.trim()),
        resprate: double.parse(_rrController.text.trim()),
        o2sat: double.parse(_o2Controller.text.trim()),
        sbp: double.parse(_sbpController.text.trim()),
        dbp: double.parse(_dbpController.text.trim()),
        pain: double.parse(_painController.text.trim()),
        gender: _gender,
        race: _race,
        arrivalTransport: _transport,
      );

      final result = await _apiService.predictUrgency(input);
      final prediction = (result['prediction'] ?? 0) as int;
      final probability = (result['probability'] ?? 0.0) as double;
      final urgencyLabel = prediction == 1 ? 'urgent' : 'not_urgent';

      await FirebaseFirestore.instance.collection('queue').add({
        'userId': user.uid,
        'patientName': user.displayName ?? user.email ?? 'Unknown',
        'complaint': _complaintController.text.trim(),
        'vitals': {
          'temperature': input.temperature,
          'heartrate': input.heartrate,
          'resprate': input.resprate,
          'o2sat': input.o2sat,
          'sbp': input.sbp,
          'dbp': input.dbp,
          'pain': input.pain,
        },
        'urgency': urgencyLabel,
        'urgencyScore': probability,
        'status': 'waiting',
        'joinedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        _resultText =
            'You have joined the queue.\n'
            'AI says: ${prediction == 1 ? "URGENT - please see a nurse soon" : "Not urgent"}\n'
            'Confidence: ${(probability * 100).toStringAsFixed(1)}%';
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _resultText = 'Could not join the queue: ${e.toString()}';
        _isError = true;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tell us how you feel'),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.teal),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Please fill in the details below. A nurse will see you soon.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextFormField(
                    controller: _complaintController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'What is the problem?',
                      helperText: 'e.g. headache, chest pain, fever',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please describe your problem';
                      }
                      return null;
                    },
                  ),
                ),
                const Text(
                  'Your measurements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _num('Body temperature (F)', 'Normal is around 98.6', _tempController),
                _num('Pulse (beats per minute)', 'Normal is 60 to 100', _hrController),
                _num('Breathing rate (per minute)', 'Normal is 12 to 20', _rrController),
                _num('Oxygen level in blood (%)', 'Normal is 95 or higher', _o2Controller),
                _num('Upper blood pressure number', 'Normal is around 120', _sbpController),
                _num('Lower blood pressure number', 'Normal is around 80', _dbpController),
                _num('Pain level (0 = none, 10 = worst)', 'How much does it hurt?', _painController),
                const SizedBox(height: 12),
                const Text(
                  'About you',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _drop('Gender', _gender, const ['F', 'M'], (v) => setState(() => _gender = v!)),
                _drop('Ethnicity', _race, const ['WHITE', 'BLACK/AFRICAN AMERICAN', 'OTHER'], (v) => setState(() => _race = v!)),
                _drop('How did you get here?', _transport, const ['WALK IN', 'AMBULANCE', 'OTHER'], (v) => setState(() => _transport = v!)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Join the Queue', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                  ),
                ),
                if (_resultText != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isError ? Colors.red.shade200 : Colors.green.shade200),
                    ),
                    child: Text(
                      _resultText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _num(String label, String helper, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Please enter a value';
          if (double.tryParse(v.trim()) == null) return 'Please enter a number';
          return null;
        },
      ),
    );
  }

  Widget _drop(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
