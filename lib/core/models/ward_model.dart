class WardModel {
  final int id;
  final String wardName;
  final String? wardNo;

  WardModel({required this.id, required this.wardName, this.wardNo});

  factory WardModel.fromJson(Map<String, dynamic> json) => WardModel(
        id: json['id'],
        wardName: json['ward_name'] ?? '',
        wardNo: json['ward_no']?.toString(),
      );
}