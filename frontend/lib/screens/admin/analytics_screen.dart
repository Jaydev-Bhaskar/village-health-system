import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Analytics'), backgroundColor: Colors.white, foregroundColor: AppTheme.charcoalText),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: ['This Week', 'This Month', '3 Months', 'All Time'].map((f) =>
                Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(f), selected: f == 'This Month', onSelected: (_) {}))
              ).toList()),
            ),
            const SizedBox(height: 20),
            // Visits Chart Placeholder
            _chartCard('Visits Completed', '1,284 total visits', Icons.bar_chart),
            const SizedBox(height: 16),
            // NCD Distribution
            _chartCard('NCD Distribution', 'Hypertension: 156, Diabetes: 89, Obesity: 42', Icons.pie_chart),
            const SizedBox(height: 16),
            // Risk Distribution
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Risk Level Distribution', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _riskBar('Normal', 0.68, AppTheme.normalGreen, '68%'),
                  _riskBar('Moderate', 0.22, AppTheme.cautionAmber, '22%'),
                  _riskBar('High Risk', 0.10, AppTheme.alertRed, '10%'),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Export Report (PDF)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartCard(String title, String subtitle, IconData icon) {
    return Card(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(color: AppTheme.lightBlueTint, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(subtitle, style: const TextStyle(color: AppTheme.mutedGrey), textAlign: TextAlign.center)),
        ),
      ]),
    ));
  }

  Widget _riskBar(String label, double value, Color color, String pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(child: LinearProgressIndicator(value: value, color: color, backgroundColor: AppTheme.softGrey, minHeight: 12)),
        const SizedBox(width: 8),
        Text(pct, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
