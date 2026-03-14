import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UploadHousesScreen extends StatelessWidget {
  const UploadHousesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Houses'), backgroundColor: Colors.white, foregroundColor: AppTheme.charcoalText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppTheme.lightBlueTint),
            child: Column(children: [
              const Icon(Icons.place, size: 48, color: AppTheme.primaryBlue),
              const SizedBox(height: 12),
              const Text('Upload House Coordinates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const Text('Supported: CSV, GeoJSON', style: TextStyle(color: AppTheme.mutedGrey)),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: () {}, child: const Text('Browse Files')),
            ]),
          ),
          const SizedBox(height: 16),
          Card(child: ListTile(
            leading: const Icon(Icons.map, color: AppTheme.primaryBlue),
            title: const Text('village_houses.csv'),
            subtitle: const Text('248 houses found', style: TextStyle(color: AppTheme.normalGreen)),
            trailing: TextButton(onPressed: () {}, child: const Text('Remove', style: TextStyle(color: AppTheme.alertRed))),
          )),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('Upload 248 Houses')),
        ]),
      ),
    );
  }
}
