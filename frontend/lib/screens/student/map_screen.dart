import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/data_models.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isLoading = true;
  String? _error;
  List<HouseData> _houses = [];
  HouseData? _selectedHouse;
  final MapController _mapController = MapController();

  // India center default
  final LatLng _defaultCenter = const LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    _fetchAssignedHouses();
  }

  Future<void> _fetchAssignedHouses() async {
    try {
      final response = await ApiService.getAssignedHouses();
      if (!mounted) return;
      final data = response['data'] as List? ?? [];
      setState(() {
        _houses = data.map((h) => HouseData.fromJson(h as Map<String, dynamic>)).toList();
        _isLoading = false;
      });

      // Fit bounds if we have houses
      if (_houses.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          final bounds = LatLngBounds.fromPoints(
            _houses.map((h) => LatLng(h.latitude, h.longitude)).toList(),
          );
          _mapController.fitCamera(CameraFit.bounds(
            bounds: bounds,
            padding: const EdgeInsets.all(50),
          ));
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _centerOnCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assigned Houses Map')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: const TextStyle(color: AppTheme.mutedGrey)),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: _fetchAssignedHouses, child: const Text('Retry')),
                  ],
                ))
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _houses.isNotEmpty
                            ? LatLng(_houses.first.latitude, _houses.first.longitude)
                            : _defaultCenter,
                        initialZoom: 13,
                        onTap: (_, __) => setState(() => _selectedHouse = null),
                      ),
                      children: [
                        // OpenStreetMap free tiles
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.villagehealth.app',
                        ),
                        MarkerLayer(
                          markers: _houses.map((h) => Marker(
                            point: LatLng(h.latitude, h.longitude),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedHouse = h),
                              child: Icon(
                                Icons.location_on,
                                color: AppTheme.riskColor(h.riskLevel),
                                size: _selectedHouse?.id == h.id ? 40 : 30,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ),

                    // Map Header Overlay
                    Positioned(
                      top: 16, left: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${_houses.length} Houses Assigned',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.charcoalText)),
                            const Icon(Icons.info_outline, color: AppTheme.primaryBlue),
                          ],
                        ),
                      ),
                    ),

                    // Current Location FAB
                    Positioned(
                      right: 16,
                      bottom: _selectedHouse != null ? 220 : 16,
                      child: FloatingActionButton(
                        onPressed: _centerOnCurrentLocation,
                        backgroundColor: AppTheme.primaryBlue,
                        child: const Icon(Icons.my_location),
                      ),
                    ),

                    // Selected House Details
                    if (_selectedHouse != null)
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: _buildHouseDetailsPanel(_selectedHouse!),
                      ),
                  ],
                ),
    );
  }

  Widget _buildHouseDetailsPanel(HouseData house) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(house.address,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.riskColor(house.riskLevel).withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  house.riskLevel[0].toUpperCase() + house.riskLevel.substring(1),
                  style: TextStyle(color: AppTheme.riskColor(house.riskLevel),
                    fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (house.lastVisit != null) ...[
            Row(children: [
              const Icon(Icons.history, size: 16, color: AppTheme.mutedGrey),
              const SizedBox(width: 8),
              Text('Last visited: ${house.lastVisit!.patientName}', style: const TextStyle(color: AppTheme.mutedGrey)),
            ]),
            const SizedBox(height: 16),
          ],
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/student/verify', arguments: house.id),
            icon: const Icon(Icons.directions_walk),
            label: const Text('Start Visit'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
