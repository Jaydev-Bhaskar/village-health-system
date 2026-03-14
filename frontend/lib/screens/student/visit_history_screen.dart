import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/data_models.dart';
import 'package:intl/intl.dart';

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<RecentVisit> _visits = [];
  String _selectedFilter = 'All';
  Map<String, int> _stats = {'total': 0, 'thisMonth': 0, 'highRisk': 0};

  final _filters = ['All', 'Today', 'This Week', 'High Risk'];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      String? period;
      String? risk;
      switch (_selectedFilter) {
        case 'Today': period = 'today'; break;
        case 'This Week': period = 'week'; break;
        case 'High Risk': risk = 'HIGH'; break;
      }

      final response = await ApiService.getVisitHistory(period: period, risk: risk);
      if (!mounted) return;
      final data = response['data'] as List? ?? [];
      setState(() {
        _visits = data.map((v) => RecentVisit.fromJson(v as Map<String, dynamic>)).toList();
        _stats = {
          'total': response['stats']?['total'] ?? 0,
          'thisMonth': response['stats']?['thisMonth'] ?? 0,
          'highRisk': response['stats']?['highRisk'] ?? 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visit History')),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        child: Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(children: _filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _selectedFilter == f,
                  onSelected: (_) {
                    setState(() => _selectedFilter = f);
                    _fetchHistory();
                  },
                ),
              )).toList()),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _miniStat('Total', '${_stats['total']}', AppTheme.primaryBlue),
                const SizedBox(width: 8),
                _miniStat('Month', '${_stats['thisMonth']}', AppTheme.primaryBlue),
                const SizedBox(width: 8),
                _miniStat('High Risk', '${_stats['highRisk']}', AppTheme.alertRed),
              ]),
            ),
            const SizedBox(height: 16),

            // Visit List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppTheme.mutedGrey)),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: _fetchHistory, child: const Text('Retry')),
                          ],
                        ))
                      : _visits.isEmpty
                          ? const Center(child: Text('No visits found', style: TextStyle(color: AppTheme.mutedGrey)))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _visits.length,
                              itemBuilder: (ctx, i) {
                                final v = _visits[i];
                                return _visitCard(
                                  v.houseAddress,
                                  v.patientName,
                                  DateFormat('MMM dd, yyyy — hh:mm a').format(v.visitDate),
                                  v.riskLevel,
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
      ]),
    ));
  }

  Widget _visitCard(String house, String patient, String date, String risk) {
    return Card(child: ListTile(
      leading: Container(width: 4, height: 48,
        decoration: BoxDecoration(color: AppTheme.riskColor(risk), borderRadius: BorderRadius.circular(2))),
      title: Text(house, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('$patient\n$date', style: const TextStyle(fontSize: 12)),
      isThreeLine: true,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.riskColor(risk).withAlpha(25), borderRadius: BorderRadius.circular(12)),
        child: Text(risk[0].toUpperCase() + risk.substring(1),
          style: TextStyle(color: AppTheme.riskColor(risk), fontSize: 11)),
      ),
    ));
  }
}
