import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';

class ClusteringScreen extends StatefulWidget {
  const ClusteringScreen({super.key});

  @override
  State<ClusteringScreen> createState() => _ClusteringScreenState();
}

class _ClusteringScreenState extends State<ClusteringScreen> {
  bool _isLoading = true;
  bool _isRunning = false;
  String? _error;
  int _totalStudents = 0;
  int _totalHouses = 0;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final dashboard = await ApiService.getAdminDashboard();
      if (!mounted) return;
      final data = dashboard['data'] ?? dashboard;
      setState(() {
        _totalStudents = data['totalStudents'] ?? 0;
        _totalHouses = data['totalHouses'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _runClustering() async {
    setState(() { _isRunning = true; _result = null; _error = null; });
    try {
      final response = await ApiService.runClustering();
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _result = response;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Smart Assignment complete!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRunning = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Clustering failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Assignment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                // Pre-run Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(children: [
                      _infoRow(Icons.person, '$_totalStudents Students Available'),
                      const Divider(),
                      _infoRow(Icons.home, '$_totalHouses Houses to Assign'),
                      const Divider(),
                      _infoRow(Icons.auto_awesome, 'Algorithm: K-Means Clustering'),
                    ]),
                  ),
                ),
                const SizedBox(height: 24),

                // Validation checks
                if (_totalStudents == 0 || _totalHouses == 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cautionAmber.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cautionAmber),
                    ),
                    child: Row(children: [
                      const Icon(Icons.warning, color: AppTheme.cautionAmber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _totalStudents == 0
                              ? 'No students uploaded yet. Please upload students first.'
                              : 'No houses uploaded yet. Please upload houses first.',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ]),
                  ),

                if (_totalStudents > 0 && _totalHouses > 0) ...[
                  // Run Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isRunning ? null : _runClustering,
                      icon: _isRunning
                          ? const SizedBox(
                              width: 24, height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.psychology),
                      label: Text(
                        _isRunning ? 'Running Smart Assignment...' : '🧠 Run Smart Assignment',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Error
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.alertRed.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.alertRed),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error, color: AppTheme.alertRed),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_error!, style: const TextStyle(fontSize: 14))),
                    ]),
                  ),

                // Results
                if (_result != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.normalGreen.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.normalGreen),
                    ),
                    child: Column(children: [
                      const Icon(Icons.check_circle, color: AppTheme.normalGreen, size: 48),
                      const SizedBox(height: 8),
                      const Text('Assignment Complete!',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(children: [
                        _resultStat('${_result!['studentsAssigned'] ?? _totalStudents}', 'Students\nAssigned'),
                        _resultStat('${_result!['housesAssigned'] ?? _result!['assignments'] ?? 0}', 'Houses\nAssigned'),
                        _resultStat('${_result!['totalClusters'] ?? 'N/A'}', 'Clusters\nCreated'),
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
    return Expanded(
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: AppTheme.mutedGrey)),
      ]),
    );
  }
}
