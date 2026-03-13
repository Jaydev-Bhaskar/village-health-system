// lib/utils/constants.dart

class AppConstants {
  static const String baseUrl = 'https://village-health-backend.onrender.com/api';

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
