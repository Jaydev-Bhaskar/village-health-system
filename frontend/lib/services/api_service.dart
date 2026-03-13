import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/house.dart';
import '../models/patient_record.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
  @override
  String toString() => message;
}

class ApiService {
  static const int _timeoutSeconds = 10;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (kDebugMode) debugPrint('API REQ: POST ${AppConstants.loginEndpoint}');
      
      final response = await http.post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) debugPrint('API RES: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Login failed: ${_parseError(response.body)}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('API ERR: $e');
      throw Exception('Network/Login Error: $e');
    }
  }

  Future<List<House>> getAssignedHouses(String studentId, String token) async {
    try {
      final url = AppConstants.studentHousesEndpoint(studentId);
      if (kDebugMode) debugPrint('API REQ: GET $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) debugPrint('API RES: ${response.statusCode}');

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        Iterable list = jsonDecode(response.body);
        return list.map((model) => House.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load houses: ${_parseError(response.body)}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('API ERR: $e');
      if (e is UnauthorizedException) rethrow;
      throw Exception('Network error fetching houses');
    }
  }

  Future<bool> verifyVisit(String houseId, double lat, double lng, String token) async {
    try {
      if (kDebugMode) debugPrint('API REQ: POST ${AppConstants.visitVerifyEndpoint}');

      final response = await http.post(
        Uri.parse(AppConstants.visitVerifyEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'houseId': houseId,
          'latitude': lat,
          'longitude': lng,
        }),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) debugPrint('API RES: ${response.statusCode}');

      _checkUnauthorized(response.statusCode);

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorMsg = _parseError(response.body);
        throw Exception(errorMsg.isNotEmpty ? errorMsg : 'Verification failed');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('API ERR: $e');
      if (e is UnauthorizedException) rethrow;
      throw Exception('$e');
    }
  }

  Future<bool> submitPatientRecord(PatientRecord record, String token) async {
    try {
      if (kDebugMode) debugPrint('API REQ: POST ${AppConstants.patientRecordEndpoint}');

      final response = await http.post(
        Uri.parse(AppConstants.patientRecordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(record.toJson()),
      ).timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) debugPrint('API RES: ${response.statusCode}');

      _checkUnauthorized(response.statusCode);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (kDebugMode) debugPrint('API ERR: $e');
      if (e is UnauthorizedException) rethrow;
      throw Exception('Failed to submit record: $e');
    }
  }

  void _checkUnauthorized(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException('Session expired. Please log in again.');
    }
  }

  String _parseError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? 'Unknown error';
    } catch (_) {
      return body;
    }
  }
}
