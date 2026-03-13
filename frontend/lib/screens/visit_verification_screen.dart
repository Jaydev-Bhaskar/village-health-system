import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import '../models/house.dart';
import '../services/location_service.dart';
import 'patient_form_screen.dart';

class VisitVerificationScreen extends StatefulWidget {
  final House house;

  const VisitVerificationScreen({Key? key, required this.house}) : super(key: key);

  @override
  State<VisitVerificationScreen> createState() => _VisitVerificationScreenState();
}

class _VisitVerificationScreenState extends State<VisitVerificationScreen> {
  final LocationService _locationService = LocationService();
  bool _isVerifying = false;
  bool _isVerified = false;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _verifyLocation() async {
    setState(() => _isVerifying = true);
    
    final position = await _locationService.getCurrentPosition();
    
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location. Ensure permissions are granted.')),
        );
      }
      setState(() => _isVerifying = false);
      return;
    }

    final isNear = _locationService.isNearHouse(
      position,
      widget.house.latitude,
      widget.house.longitude,
    );

    if (isNear) {
      setState(() {
        _isVerified = true;
        _isVerifying = false;
      });
      _initializeCamera();
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verification Failed'),
            content: const Text('You are not near the assigned house'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Try to get front camera for selfie
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _takeSelfie() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientFormScreen(
              house: widget.house,
              selfiePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take selfie: \${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit Verification')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'House: \${widget.house.address}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (!_isVerified) ...[
                _isVerifying
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _verifyLocation,
                        icon: const Icon(Icons.location_on),
                        label: const Text('Verify Location'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
              ] else if (_cameraController != null && _cameraController!.value.isInitialized) ...[
                const Text('Take a selfie for verification', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  child: CameraPreview(_cameraController!),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _takeSelfie,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Selfie'),
                ),
              ] else ...[
                 const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
