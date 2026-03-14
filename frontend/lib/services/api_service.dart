import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Central API service for all backend communication.
class ApiService {
  // Update with your backend URL
  // static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:3000/api'; // iOS simulator
  static const String baseUrl = 'https://village-health-backend.onrender.com/api'; // Production

  static const Duration _timeout = Duration(seconds: 15);

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Generic response handler with error extraction
  static dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message'] ?? 'Request failed',
      statusCode: response.statusCode,
    );
  }

  /// Safe GET request with timeout and error handling
  static Future<dynamic> _get(String path) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server unreachable');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Safe POST request with timeout and error handling
  static Future<dynamic> _post(String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Server unreachable');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Safe PATCH request
  static Future<dynamic> _patch(String path, [Map<String, dynamic>? body]) async {
    try {
      final response = await http
          .patch(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Safe PUT request
  static Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$path'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeout);
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('Login error: $e');
      return {'error': e.toString()};
    }
  }

  // ── Student ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboard() async {
    return await _get('/student/dashboard');
  }

  static Future<Map<String, dynamic>> getAssignedHouses() async {
    return await _get('/student/houses');
  }

  static Future<Map<String, dynamic>> getVisitHistory({
    int page = 1,
    int limit = 20,
    String? period,
    String? risk,
  }) async {
    String query = '?page=$page&limit=$limit';
    if (period != null) query += '&period=$period';
    if (risk != null) query += '&risk=$risk';
    return await _get('/student/visit-history$query');
  }

  // ── Visit ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> verifyVisit(
      String houseId, double lat, double lng) async {
    return await _post('/visit/verify', {
      'houseId': houseId,
      'latitude': lat,
      'longitude': lng,
    });
  }

  // ── Patient Record ────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> submitPatientRecord(
      Map<String, dynamic> data, String houseId) async {
    return await _post('/patient/record', {
      'houseId': houseId,
      ...data,
    });
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int limit = 20,
    String? channel,
    String? type,
  }) async {
    String query = '?page=$page&limit=$limit';
    if (channel != null) query += '&channel=$channel';
    if (type != null) query += '&type=$type';
    return await _get('/notifications$query');
  }

  static Future<Map<String, dynamic>> getUnreadCount() async {
    return await _get('/notifications/unread-count');
  }

  static Future<void> markNotificationRead(String id) async {
    await _patch('/notifications/$id/read');
  }

  static Future<void> markAllNotificationsRead() async {
    await _patch('/notifications/read-all');
  }

  static Future<Map<String, dynamic>> getNotificationPreferences() async {
    return await _get('/notifications/preferences');
  }

  static Future<Map<String, dynamic>> updateNotificationPreferences(
      Map<String, dynamic> prefs) async {
    return await _put('/notifications/preferences', prefs);
  }

  // ── Admin ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminDashboard() async {
    return await _get('/admin/dashboard');
  }

  static Future<Map<String, dynamic>> getAnalytics({String period = 'month'}) async {
    return await _get('/admin/analytics?period=$period');
  }

  static Future<Map<String, dynamic>> uploadStudents(List<Map<String, dynamic>> students) async {
    return await _post('/admin/upload-students', {'students': students});
  }

  static Future<Map<String, dynamic>> uploadHouses(List<Map<String, dynamic>> houses) async {
    return await _post('/admin/upload-houses', {'houses': houses});
  }

  static Future<Map<String, dynamic>> runClustering({
    int maxHouses = 8,
    double maxDistance = 2.0,
  }) async {
    return await _post('/admin/run-clustering', {
      'maxHouses': maxHouses,
      'maxDistance': maxDistance,
    });
  }
}
