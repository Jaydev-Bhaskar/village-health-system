import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/data_models.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _isLoading = true;
  String? _error;
  AnalyticsData? _data;
  String _selectedPeriod = 'month';

  final Map<String, String> _periodLabels = {
    'week': 'This Week',
    'month': 'This Month',
    '3months': '3 Months',
    'all': 'All Time',
  };

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final response = await ApiService.getAnalytics(period: _selectedPeriod);
      if (!mounted) return;
      setState(() {
        _data = AnalyticsData.fromJson(response);
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
      appBar: AppBar(title: const Text('Health Analytics')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(_error!, style: const TextStyle(color: AppTheme.mutedGrey)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _fetchAnalytics, child: const Text('Retry')),
                  ]),
                )
              : RefreshIndicator(
                  onRefresh: _fetchAnalytics,
                  child: _buildContent(),
                ),
    );
  }

  Widget _buildContent() {
    final data = _data!;
    final ncd = data.ncdDistribution;
    final risk = data.riskDistribution;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _periodLabels.entries.map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e.value),
                  selected: _selectedPeriod == e.key,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = e.key);
                      _fetchAnalytics();
                    }
                  },
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Total Visits
          _chartCard(
            'Total Visits',
            '${data.totalVisits} visits recorded',
            Icons.bar_chart,
            child: data.dailyVisits.isEmpty
                ? const Center(child: Text('No visit data', style: TextStyle(color: AppTheme.mutedGrey)))
                : _buildSimpleBarChart(data.dailyVisits),
          ),
          const SizedBox(height: 16),

          // NCD Distribution
          _chartCard(
            'NCD Distribution',
            '',
            Icons.pie_chart,
            child: Column(
              children: [
                _ncdRow('Hypertension', ncd['hypertension'] ?? 0, AppTheme.alertRed),
                _ncdRow('Diabetes', ncd['diabetes'] ?? 0, AppTheme.cautionAmber),
                _ncdRow('Obesity', ncd['obesity'] ?? 0, Colors.orange),
                _ncdRow('Normal', ncd['normal'] ?? 0, AppTheme.normalGreen),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Risk Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Risk Level Distribution',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (risk.containsKey('normal'))
                    _riskBar('Normal', (risk['normal']!.percentage) / 100.0,
                        AppTheme.normalGreen, '${risk['normal']!.percentage}% (${risk['normal']!.count})'),
                  if (risk.containsKey('moderate'))
                    _riskBar('Moderate', (risk['moderate']!.percentage) / 100.0,
                        AppTheme.cautionAmber, '${risk['moderate']!.percentage}% (${risk['moderate']!.count})'),
                  if (risk.containsKey('high'))
                    _riskBar('High Risk', (risk['high']!.percentage) / 100.0,
                        AppTheme.alertRed, '${risk['high']!.percentage}% (${risk['high']!.count})'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // BMI Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BMI Distribution',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  ...data.bmiDistribution.entries.map((e) {
                    final total = data.bmiDistribution.values.fold(0, (a, b) => a + b);
                    final pct = total > 0 ? (e.value / total) : 0.0;
                    return _riskBar(
                      e.key[0].toUpperCase() + e.key.substring(1),
                      pct,
                      _bmiColor(e.key),
                      '${e.value}',
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // House Risk Map
          if (data.houses.isNotEmpty) ...[
            _chartCard(
              'House Risk Map',
              '${data.houses.length} houses',
              Icons.map,
              child: _buildHouseMap(data.houses),
            ),
            const SizedBox(height: 8),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot('Low', AppTheme.normalGreen),
                const SizedBox(width: 16),
                _legendDot('Moderate', AppTheme.cautionAmber),
                const SizedBox(width: 16),
                _legendDot('High', AppTheme.alertRed),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.mutedGrey)),
    ]);
  }

  Widget _buildHouseMap(List<AnalyticsHouse> houses) {
    // Calculate center from all houses
    final avgLat = houses.fold(0.0, (sum, h) => sum + h.latitude) / houses.length;
    final avgLng = houses.fold(0.0, (sum, h) => sum + h.longitude) / houses.length;

    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(avgLat, avgLng),
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.villagehealth.app',
            ),
            MarkerLayer(
              markers: houses.map((h) {
                final color = _riskMarkerColor(h.riskLevel);
                return Marker(
                  point: LatLng(h.latitude, h.longitude),
                  width: 36,
                  height: 36,
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${h.address} — Risk: ${h.riskLevel}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Icon(Icons.location_on, color: color, size: 36),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _riskMarkerColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'HIGH': return AppTheme.alertRed;
      case 'MODERATE': return AppTheme.cautionAmber;
      default: return AppTheme.normalGreen;
    }
  }

  Widget _buildSimpleBarChart(List<DailyVisit> visits) {
    final maxCount = visits.fold(0, (max, v) => v.count > max ? v.count : max);
    final displayMax = maxCount > 0 ? maxCount : 1;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: visits.take(14).map((v) {
          final height = (v.count / displayMax) * 100;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Tooltip(
                message: '${v.date}: ${v.count} visits',
                child: Container(
                  height: height < 4 ? 4 : height,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _ncdRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text('$count', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ]),
    );
  }

  Widget _chartCard(String title, String subtitle, IconData icon, {Widget? child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: AppTheme.mutedGrey)),
            ],
            const SizedBox(height: 12),
            child ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _riskBar(String label, double value, Color color, String pct) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 13))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              color: color,
              backgroundColor: AppTheme.softGrey,
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(pct, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 12)),
        ),
      ]),
    );
  }

  Color _bmiColor(String category) {
    switch (category.toLowerCase()) {
      case 'underweight': return Colors.blue;
      case 'normal': return AppTheme.normalGreen;
      case 'overweight': return AppTheme.cautionAmber;
      case 'obese': return AppTheme.alertRed;
      default: return AppTheme.mutedGrey;
    }
  }
}
