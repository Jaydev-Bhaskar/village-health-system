import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/house.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'visit_verification_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<House> _houses = [];
  bool _isLoading = true;
  Set<Marker> _markers = {};

  // Default initial position (could be centered around village)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 2,
  );

  @override
  void initState() {
    super.initState();
    _fetchHouses();
  }

  Future<void> _fetchHouses() async {
    try {
      final token = await _authService.getToken();
      final studentId = await _authService.getStudentId();

      if (token == null || studentId == null) {
        throw Exception('User not authenticated');
      }

      final houses = await _apiService.getAssignedHouses(studentId, token);
      setState(() {
        _houses = houses;
        _isLoading = false;
        _createMarkers();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        if (e is UnauthorizedException) {
          await _authService.clearAuthData();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please log in again.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching houses: ${e.toString()}')),
          );
        }
      }
    }
  }

  void _createMarkers() {
    _markers = _houses.map((house) {
      double hue;
      switch (house.riskLevel.toUpperCase()) {
        case 'HIGH':
          hue = BitmapDescriptor.hueRed;
          break;
        case 'MODERATE':
          hue = BitmapDescriptor.hueYellow;
          break;
        case 'LOW':
        default:
          hue = BitmapDescriptor.hueGreen;
          break;
      }

      return Marker(
        markerId: MarkerId(house.id),
        position: LatLng(house.latitude, house.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(title: house.address, snippet: 'Risk: ${house.riskLevel}'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VisitVerificationScreen(house: house),
            ),
          );
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Assigned Houses',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Houses',
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchHouses();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await _authService.clearAuthData();
              if (mounted) {
                 Navigator.pushReplacement(
                   context,
                   MaterialPageRoute(builder: (_) => const LoginScreen()),
                 );
              }
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _houses.isNotEmpty
                  ? CameraPosition(
                      target: LatLng(_houses.first.latitude, _houses.first.longitude),
                      zoom: 14,
                    )
                  : _initialPosition,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
            ),
      floatingActionButton: _isLoading ? null : FloatingActionButton(
        onPressed: () {
             setState(() {
                _isLoading = true;
              });
              _fetchHouses();
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

