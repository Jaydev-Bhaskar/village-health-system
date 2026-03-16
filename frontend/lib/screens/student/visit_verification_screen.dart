import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';

class VisitVerificationScreen extends StatefulWidget {
  const VisitVerificationScreen({super.key});

  @override
  State<VisitVerificationScreen> createState() => _VisitVerificationScreenState();
}

class _VisitVerificationScreenState extends State<VisitVerificationScreen> {
  File? _selfieImage;
  final ImagePicker _picker = ImagePicker();
  
  // House ID from arguments (map_screen passes house.id as a String)
  String _houseId = '';
  String _houseAddress = 'Assigned House';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      // Map screen passes house.id directly as a String
      _houseId = args;
    } else if (args is Map<String, dynamic>) {
      _houseId = args['_id']?.toString() ?? args['id']?.toString() ?? '';
      _houseAddress = args['address']?.toString() ?? 'Assigned House';
    }
  }

  Future<void> _takeSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70, // compress to save bandwidth
      );
      if (photo != null) {
        setState(() {
          _selfieImage = File(photo.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take selfie: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final houseId = _houseId;
    final address = _houseAddress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Verification'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.charcoalText,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Step 1 of 2', style: TextStyle(color: AppTheme.mutedGrey, fontSize: 14)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // House Info
            Card(
              child: ListTile(
                leading: const Icon(Icons.home, color: AppTheme.primaryBlue),
                title: Text('House Assigned'),
                subtitle: Text(address),
              ),
            ),
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
            // const SizedBox(height: 16),
            // ElevatedButton(onPressed: () {}, child: const Text('Verify Location')),
            const SizedBox(height: 32),

            // Step 2: Selfie
            const Text('Selfie Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.softGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderGrey),
              ),
              clipBehavior: Clip.hardEdge,
              child: _selfieImage != null
                  ? Image.file(_selfieImage!, fit: BoxFit.cover)
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_front, size: 48, color: AppTheme.mutedGrey),
                        SizedBox(height: 8),
                        Text('No Selfie Captured', style: TextStyle(color: AppTheme.mutedGrey)),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _takeSelfie,
              icon: Icon(_selfieImage != null ? Icons.refresh : Icons.camera_alt),
              label: Text(_selfieImage != null ? 'Retake Selfie' : 'Take Selfie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selfieImage != null ? AppTheme.mutedGrey : AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _selfieImage != null
                  ? () => Navigator.pushNamed(context, '/student/patient-form', arguments: houseId)
                  : null, // Disable if selfie is not taken
              style: ElevatedButton.styleFrom(
                backgroundColor: _selfieImage != null ? AppTheme.normalGreen : AppTheme.mutedGrey,
              ),
              child: const Text('Continue to Patient Form →'),
            ),
            if (_selfieImage == null) ...[
              const SizedBox(height: 8),
              const Text('Please take a selfie to continue', style: TextStyle(color: AppTheme.alertRed, fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }
}
