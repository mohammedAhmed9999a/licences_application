class GovernorateModel {
  final int id;
  final String name;
  final double? latitude;
  final double? longitude;

  GovernorateModel({
    required this.id,
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory GovernorateModel.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString());
    }

    return GovernorateModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['name_ar'] ?? '',
      latitude: parseDouble(json['latitude'] ?? json['lat']),
      longitude: parseDouble(json['longitude'] ?? json['lng']),
    );
  }
}
