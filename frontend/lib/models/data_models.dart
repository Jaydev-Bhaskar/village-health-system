/// Data models for the Village Health Monitoring System

class DashboardData {
  final int assignedHouses;
  final int visitsToday;
  final int pendingVisits;
  final int totalVisits;
  final String studentName;
  final List<RecentVisit> recentVisits;

  DashboardData({
    required this.assignedHouses,
    required this.visitsToday,
    required this.pendingVisits,
    required this.totalVisits,
    required this.studentName,
    required this.recentVisits,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return DashboardData(
      assignedHouses: data['assignedHouses'] ?? 0,
      visitsToday: data['visitsToday'] ?? 0,
      pendingVisits: data['pendingVisits'] ?? 0,
      totalVisits: data['totalVisits'] ?? 0,
      studentName: data['studentName'] ?? 'Student',
      recentVisits: (data['recentVisits'] as List?)
              ?.map((v) => RecentVisit.fromJson(v))
              .toList() ??
          [],
    );
  }
}

class RecentVisit {
  final String id;
  final String houseId;
  final String houseAddress;
  final String riskLevel;
  final String patientName;
  final DateTime visitDate;
  final String disease;

  RecentVisit({
    required this.id,
    required this.houseId,
    required this.houseAddress,
    required this.riskLevel,
    required this.patientName,
    required this.visitDate,
    required this.disease,
  });

  factory RecentVisit.fromJson(Map<String, dynamic> json) {
    return RecentVisit(
      id: json['id'] ?? '',
      houseId: json['houseId'] ?? '',
      houseAddress: json['houseAddress'] ?? 'Unknown House',
      riskLevel: (json['riskLevel'] ?? 'LOW').toString().toLowerCase(),
      patientName: json['patientName'] ?? 'Unknown',
      visitDate: DateTime.tryParse(json['visitDate'] ?? '') ?? DateTime.now(),
      disease: json['disease'] ?? '',
    );
  }
}

class HouseData {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String riskLevel;
  final String? assignedStudentId;
  final LastVisitInfo? lastVisit;

  HouseData({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    this.assignedStudentId,
    this.lastVisit,
  });

  factory HouseData.fromJson(Map<String, dynamic> json) {
    return HouseData(
      id: json['_id'] ?? json['id'] ?? '',
      address: json['address'] ?? 'Unknown',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      riskLevel: (json['riskLevel'] ?? 'LOW').toString().toLowerCase(),
      assignedStudentId: json['assignedStudentId'],
      lastVisit: json['lastVisit'] != null
          ? LastVisitInfo.fromJson(json['lastVisit'])
          : null,
    );
  }
}

class LastVisitInfo {
  final DateTime date;
  final String patientName;
  final String risk;

  LastVisitInfo({required this.date, required this.patientName, required this.risk});

  factory LastVisitInfo.fromJson(Map<String, dynamic> json) {
    return LastVisitInfo(
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      patientName: json['patientName'] ?? '',
      risk: (json['risk'] ?? 'LOW').toString().toLowerCase(),
    );
  }
}

class PatientFormData {
  // Basic Persona
  String name = '';
  int? age;
  String sex = 'Male';
  String religion = '';
  String caste = '';
  String address = '';
  double? weight;
  double? height;
  String? patientPhone;

  // Family History
  Set<String> familyHistory = {};

  // Personal History
  String diet = 'Mixed';
  String sleepPattern = '';
  String bowelHabit = 'Regular';
  bool smoking = false;
  bool alcohol = false;
  bool tobacco = false;
  String allergies = '';

  // Female Health
  String menstrualRegularity = 'Regular';
  String lmp = '';
  bool isPregnant = false;

  // Vitals
  int? systolic;
  int? diastolic;
  int? heartRate;
  int? respiratoryRate;
  int? pulseRate;
  double? bloodSugar;

  // Pediatric
  double? muac;
  double? headCircumference;
  double? chestCircumference;
  Set<String> vaccinations = {};

  // Maternal
  int? gravida;
  int? para;
  int? abortions;
  int? stillBirths;
  int? gestationalAge;

  // Computed
  double get bmi {
    if (weight != null && height != null && height! > 0) {
      return weight! / ((height! / 100) * (height! / 100));
    }
    return 0;
  }

  String get bmiCategory {
    final b = bmi;
    if (b == 0) return 'N/A';
    if (b < 16.0) return 'Severe underweight';
    if (b < 17.0) return 'Moderate underweight';
    if (b < 18.5) return 'Mild underweight';
    if (b < 25.0) return 'Normal range';
    if (b < 30.0) return 'Pre-obese';
    if (b < 35.0) return 'Obese class I';
    if (b < 40.0) return 'Obese class II';
    return 'Obese class III';
  }

  String get hypertensionRisk {
    if (systolic == null || diastolic == null) return 'N/A';
    if (systolic! >= 160 || diastolic! >= 100) return 'Stage 2 Hypertension';
    if (systolic! >= 140 || diastolic! >= 90) return 'Stage 1 Hypertension';
    if (systolic! >= 120 || diastolic! >= 80) return 'Elevated / Pre Hypertension';
    return 'Normal';
  }

  String get diabetesRisk {
    if (bloodSugar == null) return 'N/A';
    if (bloodSugar! >= 200) return 'Diabetes';
    if (bloodSugar! >= 140) return 'Prediabetes';
    return 'Normal';
  }

  String get overallRisk {
    final risks = [hypertensionRisk, diabetesRisk];
    if (bmiCategory.contains('Obese')) risks.add('high');
    
    if (risks.any((r) => r.contains('Stage 2') || r.contains('Stage 1') || r.contains('Diabetes') || r == 'high')) {
      return 'high';
    }
    if (risks.any((r) => r.contains('Elevated') || r.contains('Prediabetes'))) {
      return 'moderate';
    }
    return 'normal';
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': name,
      'age': age,
      'sex': sex,
      'religion': religion,
      'caste': caste,
      'address': address,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
      'patientPhone': patientPhone,
      'familyHistory': familyHistory.toList(),
      'personalHistory': {
        'diet': diet,
        'sleep': sleepPattern,
        'bowelHabit': bowelHabit,
        'smoking': smoking,
        'alcohol': alcohol,
        'tobacco': tobacco,
        'allergies': allergies,
      },
      'femaleHealth': {
        'menstrualRegularity': menstrualRegularity,
        'lmp': lmp,
        'isPregnant': isPregnant,
      },
      'disease': _computeDiseaseString(),
      'bloodPressure': '${systolic ?? 0}/${diastolic ?? 0}',
      'vitals': {
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
        'respiratoryRate': respiratoryRate,
        'pulseRate': pulseRate,
        'bloodSugar': bloodSugar,
      },
      'pediatric': {
        'muac': muac,
        'headCircumference': headCircumference,
        'chestCircumference': chestCircumference,
        'vaccinations': vaccinations.toList(),
      },
      'maternal': {
        'gravida': gravida,
        'para': para,
        'abortions': abortions,
        'stillBirths': stillBirths,
        'gestationalAge': gestationalAge,
      },
      'riskResult': {
        'hypertension': hypertensionRisk,
        'diabetes': diabetesRisk,
        'obesity': bmiCategory == 'Obese' ? 'high' : 'normal',
        'overallRisk': overallRisk.toUpperCase(),
        'bmiCategory': bmiCategory,
      },
    };
  }

  String _computeDiseaseString() {
    final diseases = <String>[];
    if (hypertensionRisk == 'high') diseases.add('Hypertension');
    if (diabetesRisk == 'high') diseases.add('Diabetes');
    if (bmiCategory == 'Obese') diseases.add('Obesity');
    return diseases.isEmpty ? 'None' : diseases.join(', ');
  }
}

class AdminDashboardData {
  final int totalHouses;
  final int totalStudents;
  final int totalVisits;
  final int highRiskPatients;

  AdminDashboardData({
    required this.totalHouses,
    required this.totalStudents,
    required this.totalVisits,
    required this.highRiskPatients,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return AdminDashboardData(
      totalHouses: data['totalHouses'] ?? 0,
      totalStudents: data['totalStudents'] ?? 0,
      totalVisits: data['totalVisits'] ?? 0,
      highRiskPatients: data['highRiskPatients'] ?? 0,
    );
  }
}

class AnalyticsData {
  final int totalVisits;
  final List<DailyVisit> dailyVisits;
  final Map<String, int> ncdDistribution;
  final Map<String, RiskStat> riskDistribution;
  final Map<String, int> bmiDistribution;
  final List<AnalyticsHouse> houses;

  AnalyticsData({
    required this.totalVisits,
    required this.dailyVisits,
    required this.ncdDistribution,
    required this.riskDistribution,
    required this.bmiDistribution,
    required this.houses,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Safe int map parsing (handles both int and double from JSON)
    final ncdRaw = data['ncdDistribution'] as Map<String, dynamic>? ?? {};
    final ncd = ncdRaw.map((k, v) => MapEntry(k, (v is num) ? v.toInt() : 0));
    
    final bmiRaw = data['bmiDistribution'] as Map<String, dynamic>? ?? {};
    final bmi = bmiRaw.map((k, v) => MapEntry(k, (v is num) ? v.toInt() : 0));
    
    // Safe risk distribution parsing
    final riskRaw = data['riskDistribution'] as Map<String, dynamic>? ?? {};
    final risk = <String, RiskStat>{};
    riskRaw.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        risk[k] = RiskStat.fromJson(v);
      } else {
        risk[k] = RiskStat(count: 0, percentage: 0);
      }
    });

    // Parse houses
    final housesList = (data['houses'] as List? ?? [])
        .map((h) => AnalyticsHouse.fromJson(h as Map<String, dynamic>))
        .toList();

    return AnalyticsData(
      totalVisits: (data['totalVisits'] is num) ? (data['totalVisits'] as num).toInt() : 0,
      dailyVisits: (data['dailyVisits'] as List?)
              ?.map((d) => DailyVisit.fromJson(d))
              .toList() ??
          [],
      ncdDistribution: ncd,
      riskDistribution: risk,
      bmiDistribution: bmi,
      houses: housesList,
    );
  }
}

class AnalyticsHouse {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String riskLevel;

  AnalyticsHouse({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
  });

  factory AnalyticsHouse.fromJson(Map<String, dynamic> json) {
    return AnalyticsHouse(
      id: json['id']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] is num) ? (json['latitude'] as num).toDouble() : 0.0,
      longitude: (json['longitude'] is num) ? (json['longitude'] as num).toDouble() : 0.0,
      riskLevel: json['riskLevel']?.toString() ?? 'LOW',
    );
  }
}

class DailyVisit {
  final String date;
  final int count;
  DailyVisit({required this.date, required this.count});

  factory DailyVisit.fromJson(Map<String, dynamic> json) {
    return DailyVisit(
      date: json['date'] ?? '',
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
    );
  }
}

class RiskStat {
  final int count;
  final int percentage;
  RiskStat({required this.count, required this.percentage});

  factory RiskStat.fromJson(Map<String, dynamic> json) {
    return RiskStat(
      count: (json['count'] is num) ? (json['count'] as num).toInt() : 0,
      percentage: (json['percentage'] is num) ? (json['percentage'] as num).toInt() : 0,
    );
  }
}
