class LocalityModel {
  final int id;
  final String localityName;
  final int? wardId;

  LocalityModel({required this.id, required this.localityName, this.wardId});

  factory LocalityModel.fromJson(Map<String, dynamic> json) => LocalityModel(
        id: json['id'],
        localityName: json['locality_name'] ?? '',
        wardId: json['ward_id'],
      );
}