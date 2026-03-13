// lib/utils/constants.dart
// NOTE: Change baseUrl to your deployed backend IP/domain before release.

class AppConstants {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // 10.0.2.2 routes to localhost on Android emulator

  // Auth Endpoints
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';

  // Student Endpoints
  static String studentHousesEndpoint(String studentId) =>
      '$baseUrl/student/houses/$studentId';

  // Visit Endpoint
  static const String visitVerifyEndpoint = '$baseUrl/visit/verify';

  // Patient Endpoint
  static const String patientRecordEndpoint = '$baseUrl/patient/record';

  // Distance Threshold for Visit Verification (in meters)
  static const double visitDistanceThreshold = 30.0;
}
