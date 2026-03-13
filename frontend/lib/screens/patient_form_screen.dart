import 'package:flutter/material.dart';
import 'dart:io';
import '../models/house.dart';
import '../models/patient_record.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

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
        if (e is UnauthorizedException) {
          await _authService.clearAuthData();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission Error: ${e.toString().replaceAll('Exception: ', '')}')),
          );
        }
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Patient Health Form'),
        elevation: 0,
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.selfiePath.isNotEmpty)
                   Center(
                     child: Container(
                       height: 120,
                       width: 120,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.green.shade300, width: 4),
                         image: DecorationImage(
                           image: FileImage(File(widget.selfiePath)),
                           fit: BoxFit.cover,
                         ),
                       ),
                     ),
                   ),
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.house, color: Colors.green.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.house.address,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _nameController,
                  label: 'Patient Name',
                  icon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _diseaseController,
                  label: 'Disease / Symptoms',
                  icon: Icons.sick_outlined,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _bpController,
                  label: 'Blood Pressure (e.g., 120/80)',
                  icon: Icons.favorite_border,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _notesController,
                  label: 'Additional Notes',
                  icon: Icons.note_alt_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                _isSubmitting
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.green.shade700,
                           foregroundColor: Colors.white,
                           padding: const EdgeInsets.symmetric(vertical: 16),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(12),
                           ),
                           elevation: 3,
                        ),
                        child: const Text('Submit Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : Padding(padding: const EdgeInsets.only(bottom: 50.0), child: Icon(icon)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
    );
  }
}

