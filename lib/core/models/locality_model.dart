class LocalityModel {
  final int id;
  final String localityName;
  final int? wardId;

  LocalityModel({required this.id, required this.localityName, this.wardId});

  factory LocalityModel.fromJson(Map<String, dynamic> json) => LocalityModel(
        id: json['id'] ?? 0,
        localityName: json['locality'] ?? json['locality_name'] ?? '',
        wardId: json['ward_id'] is int
            ? json['ward_id']
            : int.tryParse(json['ward_id']?.toString() ?? ''),
      );
}