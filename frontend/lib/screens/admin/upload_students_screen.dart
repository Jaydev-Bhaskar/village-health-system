import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UploadStudentsScreen extends StatelessWidget {
  const UploadStudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Students'), backgroundColor: Colors.white, foregroundColor: AppTheme.charcoalText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Upload Zone
          Container(
            width: double.infinity, padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryBlue, width: 2, style: BorderStyle.none),
              borderRadius: BorderRadius.circular(12), color: AppTheme.lightBlueTint,
            ),
            child: Column(children: [
              const Icon(Icons.cloud_upload, size: 48, color: AppTheme.primaryBlue),
              const SizedBox(height: 12),
              const Text('Upload CSV File', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const Text('Supported: .csv', style: TextStyle(color: AppTheme.mutedGrey)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Browse Files')),
            ]),
          ),
          const SizedBox(height: 16),
          // File Info
          Card(child: ListTile(
            leading: const Icon(Icons.description, color: AppTheme.primaryBlue),
            title: const Text('students_batch_2026.csv'),
            subtitle: const Text('45 records found', style: TextStyle(color: AppTheme.normalGreen)),
            trailing: TextButton(onPressed: () {}, child: const Text('Remove', style: TextStyle(color: AppTheme.alertRed))),
          )),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('Upload 45 Students')),
        ]),
      ),
    );
  }
}
