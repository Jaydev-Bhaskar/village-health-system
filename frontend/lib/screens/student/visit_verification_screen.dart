import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VisitVerificationScreen extends StatelessWidget {
  const VisitVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Verification'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.charcoalText,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('Step 1 of 2', style: TextStyle(color: AppTheme.mutedGrey, fontSize: 14))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // House Info
            Card(child: ListTile(
              leading: const Icon(Icons.home, color: AppTheme.primaryBlue),
              title: const Text('House #H-042'),
              subtitle: const Text('Village: Rampur'),
            )),
            const SizedBox(height: 24),

            // Step 1: Location
            const Text('Location Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.lightBlueTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.map, size: 48, color: AppTheme.primaryBlue)),
            ),
            const SizedBox(height: 16),
            const Text('45m', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
            const Text('Distance to House', style: TextStyle(color: AppTheme.mutedGrey)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.normalGreen.withAlpha(25),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppTheme.normalGreen, size: 20),
                  SizedBox(width: 8),
                  Text('Within Range', style: TextStyle(color: AppTheme.normalGreen, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () {}, child: const Text('Verify Location')),
            const SizedBox(height: 32),

            // Step 2: Selfie
            const Text('Selfie Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: AppTheme.softGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 48, color: AppTheme.mutedGrey),
                    SizedBox(height: 8),
                    Text('Camera Preview', style: TextStyle(color: AppTheme.mutedGrey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Selfie'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/student/patient-form'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.normalGreen),
              child: const Text('Continue to Patient Form →'),
            ),
          ],
        ),
      ),
    );
  }
}
