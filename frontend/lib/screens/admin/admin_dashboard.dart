import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/data_models.dart';
import '../../providers/auth_provider.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  String? _error;
  AdminDashboardData? _data;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiService.getAdminDashboard();
      if (!mounted) return;
      setState(() {
        _data = AdminDashboardData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.pushNamed(context, '/notifications/settings')),
          IconButton(icon: const Icon(Icons.logout), onPressed: () {
            auth.logout();
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_error!, style: const TextStyle(color: AppTheme.mutedGrey)),
                  const SizedBox(height: 12), ElevatedButton(onPressed: _fetchDashboard, child: const Text('Retry'))]))
              : RefreshIndicator(
                  onRefresh: _fetchDashboard,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Administration Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text('Welcome, Administrator', style: TextStyle(color: AppTheme.mutedGrey)),
        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 2, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
          children: [
            _statCard('${data.totalHouses}', 'Total Houses', Icons.home, AppTheme.primaryBlue),
            _statCard('${data.totalStudents}', 'Total Students', Icons.people, AppTheme.primaryBlue),
            _statCard('${data.totalVisits}', 'Total Visits', Icons.check_circle, AppTheme.normalGreen),
            _statCard('${data.highRiskPatients}', 'High Risk', Icons.warning, AppTheme.alertRed),
          ],
        ),
        const SizedBox(height: 24),

        _actionCard('Upload Students', 'Import student CSV data', Icons.upload_file, '/admin/upload-students'),
        _actionCard('Upload Houses', 'Import house coordinates', Icons.map, '/admin/upload-houses'),
        _actionCard('Run Clustering', 'Smart house assignment', Icons.auto_awesome, '/admin/clustering'),
        _actionCard('View Analytics', 'Health data analytics', Icons.bar_chart, '/admin/analytics'),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 28), const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
      ]),
    );
  }

  Widget _actionCard(String title, String subtitle, IconData icon, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.lightBlueTint, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.mutedGrey),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
