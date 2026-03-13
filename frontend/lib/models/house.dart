class House {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String riskLevel; // LOW, MODERATE, HIGH

  House({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
  });

  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['_id'] ?? json['id'] ?? '',
      address: json['address'] ?? 'Unknown Address',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      riskLevel: json['riskLevel'] ?? 'LOW',
    );
  }
}
