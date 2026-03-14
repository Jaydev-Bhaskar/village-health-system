import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/data_models.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _error;
  DashboardData? _data;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ApiService.getDashboard(),
        ApiService.getUnreadCount().catchError((e) {
          debugPrint('Notifications fetch error: $e');
          return {'count': 0};
        }),
      ]);
      if (!mounted) return;
      setState(() {
        _data = DashboardData.fromJson(results[0]);
        _unreadNotifications = results[1]['unreadCount'] ?? results[1]['count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.pushNamed(context, '/notifications/settings'),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.alertRed, shape: BoxShape.circle),
                    child: Text(
                      _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _fetchDashboard,
                  child: _buildContent(dateFormat),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == _currentIndex) return;
          setState(() => _currentIndex = i);
          switch (i) {
            case 1:
              Navigator.pushNamed(context, '/student/map');
              break;
            case 2:
              Navigator.pushNamed(context, '/student/history');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: AppTheme.mutedGrey),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.mutedGrey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DateFormat dateFormat) {
    final data = _data!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Welcome
        Text('Good Morning, ${data.studentName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.charcoalText)),
        Text('Field Visit Day — ${dateFormat.format(DateTime.now())}',
            style: const TextStyle(fontSize: 14, color: AppTheme.mutedGrey)),
        const SizedBox(height: 20),

        // Summary Cards
        Row(
          children: [
            _buildStatCard('${data.assignedHouses}', 'Assigned\nHouses', Icons.home, AppTheme.primaryBlue),
            const SizedBox(width: 12),
            _buildStatCard('${data.visitsToday}', 'Visits\nToday', Icons.check_circle, AppTheme.normalGreen),
            const SizedBox(width: 12),
            _buildStatCard('${data.pendingVisits}', 'Pending\nVisits', Icons.schedule, AppTheme.cautionAmber),
          ],
        ),
        const SizedBox(height: 24),

        // Quick Actions
        ElevatedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/student/map'),
          icon: const Icon(Icons.map),
          label: const Text('Open Map'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/student/history'),
          icon: const Icon(Icons.history),
          label: const Text('View Visit History'),
        ),
        const SizedBox(height: 24),

        // Recent Visits
        const Text('Recent Visits',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.charcoalText)),
        const SizedBox(height: 12),

        if (data.recentVisits.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No visits yet. Start by opening the map!',
                    style: TextStyle(color: AppTheme.mutedGrey)),
              ),
            ),
          )
        else
          ...data.recentVisits.map((v) => _buildVisitCard(
                v.houseAddress,
                v.patientName,
                DateFormat('MMM dd, yyyy').format(v.visitDate),
                v.riskLevel,
              )),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(String house, String patient, String date, String risk) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.riskColor(risk),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(house, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('$patient — $date'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.riskColor(risk).withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            risk[0].toUpperCase() + risk.substring(1),
            style: TextStyle(color: AppTheme.riskColor(risk), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
