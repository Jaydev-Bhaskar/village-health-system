import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ClusteringScreen extends StatelessWidget {
  const ClusteringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Assignment'), backgroundColor: Colors.white, foregroundColor: AppTheme.charcoalText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Pre-run Info
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
            _infoRow(Icons.person, '45 Students Available'),
            const Divider(),
            _infoRow(Icons.home, '248 Houses to Assign'),
            const Divider(),
            _infoRow(Icons.auto_awesome, 'Algorithm: K-Means'),
          ]))),
          const SizedBox(height: 24),
          // Run Button
          SizedBox(width: double.infinity, height: 56, child:
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.psychology),
              label: const Text('🧠 Run Smart Assignment', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
          // Results
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.normalGreen.withAlpha(25), borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.normalGreen),
            ),
            child: Column(children: [
              const Icon(Icons.check_circle, color: AppTheme.normalGreen, size: 48),
              const SizedBox(height: 8),
              const Text('Assignment Complete!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                _resultStat('45', 'Students\nAssigned'),
                _resultStat('248', 'Houses\nClustered'),
                _resultStat('8', 'Clusters\nCreated'),
                _resultStat('1.2km', 'Avg\nDistance'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, color: AppTheme.primaryBlue),
      const SizedBox(width: 12),
      Text(text, style: const TextStyle(fontSize: 16)),
    ]);
  }

  Widget _resultStat(String value, String label) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
    ]));
  }
}
