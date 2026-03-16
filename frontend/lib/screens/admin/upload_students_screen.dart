import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class UploadStudentsScreen extends StatefulWidget {
  const UploadStudentsScreen({super.key});

  @override
  State<UploadStudentsScreen> createState() => _UploadStudentsScreenState();
}

class _UploadStudentsScreenState extends State<UploadStudentsScreen> {
  String? _fileName;
  List<Map<String, dynamic>> _parsedStudents = [];
  bool _isUploading = false;
  String? _uploadResult;
  bool _uploadSuccess = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;

        if (bytes == null) {
          _showSnack('Could not read file');
          return;
        }

        final content = utf8.decode(bytes);
        final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();

        if (lines.length < 2) {
          _showSnack('CSV file must have a header row and at least one data row');
          return;
        }

        // Parse header
        final headers = lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();
        
        // Find column indices - support various header names
        int studentIdIdx = headers.indexWhere((h) => 
          h == 'studentid' || h == 'student_id' || h == 'id' || h == 'roll' || h == 'rollno' || h == 'roll_no');
        int nameIdx = headers.indexWhere((h) => h == 'name' || h == 'student_name' || h == 'studentname');
        int emailIdx = headers.indexWhere((h) => h == 'email' || h == 'mail' || h == 'emailid');

        if (studentIdIdx == -1) {
          _showSnack('CSV must have a studentId/id/roll column');
          return;
        }

        final students = <Map<String, dynamic>>[];
        for (int i = 1; i < lines.length; i++) {
          final cols = lines[i].split(',').map((c) => c.trim()).toList();
          if (cols.length <= studentIdIdx) continue;
          
          final student = <String, dynamic>{
            'studentId': cols[studentIdIdx],
          };
          
          if (nameIdx != -1 && cols.length > nameIdx && cols[nameIdx].isNotEmpty) {
            student['name'] = cols[nameIdx];
          }
          if (emailIdx != -1 && cols.length > emailIdx && cols[emailIdx].isNotEmpty) {
            student['email'] = cols[emailIdx];
          }
          
          if (student['studentId']?.isNotEmpty == true) {
            students.add(student);
          }
        }

        setState(() {
          _fileName = file.name;
          _parsedStudents = students;
          _uploadResult = null;
        });
      }
    } catch (e) {
      _showSnack('Error reading file: $e');
    }
  }

  Future<void> _uploadStudents() async {
    if (_parsedStudents.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });

    try {
      final response = await ApiService.uploadStudents(_parsedStudents);
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadSuccess = true;
        _uploadResult = response['message'] ?? 'Upload complete';
      });
      _showSnack('✅ ${response['message']}');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadSuccess = false;
        _uploadResult = e.toString();
      });
      _showSnack('❌ Upload failed: $e');
    }
  }

  void _removeFile() {
    setState(() {
      _fileName = null;
      _parsedStudents = [];
      _uploadResult = null;
    });
  }

  void _showSnack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Students')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Instructions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                    SizedBox(width: 8),
                    Text('CSV Format', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ]),
                  const SizedBox(height: 8),
                  const Text(
                    'Required columns: studentId (or id/roll)\n'
                    'Optional columns: name, email\n\n'
                    '• If student ID already exists, it will be skipped\n'
                    '• New students get their Student ID as password\n'
                    '• Email is optional',
                    style: TextStyle(color: AppTheme.mutedGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Upload Zone
          InkWell(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryBlue, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.lightBlueTint,
              ),
              child: Column(children: [
                const Icon(Icons.cloud_upload, size: 48, color: AppTheme.primaryBlue),
                const SizedBox(height: 12),
                const Text('Upload CSV File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Text('Tap to browse • Supported: .csv', style: TextStyle(color: AppTheme.mutedGrey)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Browse Files'),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // File Info
          if (_fileName != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.description, color: AppTheme.primaryBlue),
                title: Text(_fileName!),
                subtitle: Text(
                  '${_parsedStudents.length} student records found',
                  style: const TextStyle(color: AppTheme.normalGreen),
                ),
                trailing: TextButton(
                  onPressed: _removeFile,
                  child: const Text('Remove', style: TextStyle(color: AppTheme.alertRed)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Preview first few records
            if (_parsedStudents.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preview (first 5 records)', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      ..._parsedStudents.take(5).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          const Icon(Icons.person, size: 16, color: AppTheme.mutedGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${s['studentId']} — ${s['name'] ?? 'No name'} ${s['email'] != null ? '(${s['email']})' : ''}',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      )),
                      if (_parsedStudents.length > 5)
                        Text('...and ${_parsedStudents.length - 5} more',
                          style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadStudents,
                icon: _isUploading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload ${_parsedStudents.length} Students'),
              ),
            ),
          ],

          // Result
          if (_uploadResult != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _uploadSuccess ? AppTheme.normalGreen.withAlpha(25) : AppTheme.alertRed.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _uploadSuccess ? AppTheme.normalGreen : AppTheme.alertRed),
              ),
              child: Row(children: [
                Icon(
                  _uploadSuccess ? Icons.check_circle : Icons.error,
                  color: _uploadSuccess ? AppTheme.normalGreen : AppTheme.alertRed,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_uploadResult!, style: const TextStyle(fontSize: 14))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }
}
