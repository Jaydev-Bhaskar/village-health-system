import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/house.dart';
import '../models/patient_record.dart';

class ApiService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to login: \${response.body}');
      }
    } catch (e) {
      throw Exception('Login Error: \$e');
    }
  }

  Future<List<House>> getAssignedHouses(String studentId, String token) async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.studentHousesEndpoint(studentId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$token',
        },
      );

      if (response.statusCode == 200) {
        Iterable list = jsonDecode(response.body);
        return list.map((model) => House.fromJson(model)).toList();
      } else {
        throw Exception('Failed to load houses');
      }
    } catch (e) {
      throw Exception('Network error');
    }
  }

  Future<bool> submitPatientRecord(PatientRecord record, String token) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.patientRecordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer \$token',
        },
        body: jsonEncode(record.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to submit record');
    }
  }
}
