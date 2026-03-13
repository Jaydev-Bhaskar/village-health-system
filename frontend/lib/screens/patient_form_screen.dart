import 'package:flutter/material.dart';
import 'dart:io';
import '../models/house.dart';
import '../models/patient_record.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class PatientFormScreen extends StatefulWidget {
  final House house;
  final String selfiePath;

  const PatientFormScreen({
    Key? key,
    required this.house,
    required this.selfiePath,
  }) : super(key: key);

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _bpController = TextEditingController();
  final _notesController = TextEditingController();
  
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Authentication token missing');

      final record = PatientRecord(
        houseId: widget.house.id,
        patientName: _nameController.text.trim(),
        disease: _diseaseController.text.trim(),
        bloodPressure: _bpController.text.trim(),
        notes: _notesController.text.trim(),
      );

      final success = await _apiService.submitPatientRecord(record, token);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Record submitted successfully')),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        throw Exception('Failed to submit');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission Error: \${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diseaseController.dispose();
    _bpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Health Form')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.selfiePath.isNotEmpty)
                   SizedBox(
                     height: 100,
                     child: Image.file(File(widget.selfiePath), fit: BoxFit.contain),
                   ),
                const SizedBox(height: 16),
                Text(
                  'House: \${widget.house.address}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _diseaseController,
                  decoration: const InputDecoration(labelText: 'Disease / Symptoms', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bpController,
                  decoration: const InputDecoration(labelText: 'Blood Pressure (e.g., 120/80)', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Additional Notes', border: OutlineInputBorder()),
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Submit Record'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
