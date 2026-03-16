import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class UploadHousesScreen extends StatefulWidget {
  const UploadHousesScreen({super.key});

  @override
  State<UploadHousesScreen> createState() => _UploadHousesScreenState();
}

class _UploadHousesScreenState extends State<UploadHousesScreen> {
  String? _fileName;
  List<Map<String, dynamic>> _parsedHouses = [];
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
          _showSnack('CSV must have header row and at least one data row');
          return;
        }

        final headers = lines[0].split(',').map((h) => h.trim().toLowerCase()).toList();

        int addressIdx = headers.indexWhere((h) =>
            h == 'address' || h == 'location' || h == 'name' || h == 'house');
        int latIdx = headers.indexWhere((h) =>
            h == 'latitude' || h == 'lat');
        int lngIdx = headers.indexWhere((h) =>
            h == 'longitude' || h == 'lng' || h == 'lon' || h == 'long');

        if (latIdx == -1 || lngIdx == -1) {
          _showSnack('CSV must have latitude and longitude columns');
          return;
        }

        final houses = <Map<String, dynamic>>[];
        for (int i = 1; i < lines.length; i++) {
          final cols = lines[i].split(',').map((c) => c.trim()).toList();
          if (cols.length <= lngIdx) continue;

          final lat = double.tryParse(cols[latIdx]);
          final lng = double.tryParse(cols[lngIdx]);
          if (lat == null || lng == null) continue;

          houses.add({
            'address': addressIdx != -1 && cols.length > addressIdx ? cols[addressIdx] : 'House $i',
            'latitude': lat,
            'longitude': lng,
          });
        }

        setState(() {
          _fileName = file.name;
          _parsedHouses = houses;
          _uploadResult = null;
        });
      }
    } catch (e) {
      _showSnack('Error reading file: $e');
    }
  }

  Future<void> _uploadHouses() async {
    if (_parsedHouses.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadResult = null;
    });

    try {
      final response = await ApiService.uploadHouses(_parsedHouses);
      if (!mounted) return;
      setState(() {
        _isUploading = false;
        _uploadSuccess = true;
        _uploadResult = '${response['message']} — ${response['count']} houses added';
      });
      _showSnack('✅ Houses uploaded successfully');
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
      _parsedHouses = [];
      _uploadResult = null;
    });
  }

  void _showSnack(String msg) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Houses')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Instructions
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
                    'Required columns: latitude (or lat), longitude (or lng/lon)\n'
                    'Optional columns: address (or location/name)',
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
                const Icon(Icons.place, size: 48, color: AppTheme.primaryBlue),
                const SizedBox(height: 12),
                const Text('Upload House Coordinates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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

          if (_fileName != null) ...[
            Card(
              child: ListTile(
                leading: const Icon(Icons.map, color: AppTheme.primaryBlue),
                title: Text(_fileName!),
                subtitle: Text(
                  '${_parsedHouses.length} houses found',
                  style: const TextStyle(color: AppTheme.normalGreen),
                ),
                trailing: TextButton(
                  onPressed: _removeFile,
                  child: const Text('Remove', style: TextStyle(color: AppTheme.alertRed)),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Preview
            if (_parsedHouses.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preview (first 5)', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      ..._parsedHouses.take(5).map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          const Icon(Icons.home, size: 16, color: AppTheme.mutedGrey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${h['address']} (${h['latitude']}, ${h['longitude']})',
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ]),
                      )),
                      if (_parsedHouses.length > 5)
                        Text('...and ${_parsedHouses.length - 5} more',
                          style: const TextStyle(color: AppTheme.mutedGrey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _uploadHouses,
                icon: _isUploading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.upload),
                label: Text(_isUploading ? 'Uploading...' : 'Upload ${_parsedHouses.length} Houses'),
              ),
            ),
          ],

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
