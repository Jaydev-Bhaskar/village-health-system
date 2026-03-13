class PatientRecord {
  final String houseId;
  final String patientName;
  final String disease;
  final String bloodPressure;
  final String notes;

  PatientRecord({
    required this.houseId,
    required this.patientName,
    required this.disease,
    required this.bloodPressure,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'houseId': houseId,
      'patientName': patientName,
      'disease': disease,
      'bloodPressure': bloodPressure,
      'notes': notes,
    };
  }
}
