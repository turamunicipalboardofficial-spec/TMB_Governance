class WardModel {
  final int id;
  final String wardName;
  final String? wardNo;

  WardModel({required this.id, required this.wardName, this.wardNo});

  factory WardModel.fromJson(Map<String, dynamic> json) {
    final wardNo = json['ward_no'];
    return WardModel(
      id: json['id'] ?? (wardNo is int ? wardNo : int.tryParse(wardNo?.toString() ?? '') ?? 0),
      wardName: json['ward_name'] ?? 'Ward $wardNo',
      wardNo: wardNo?.toString(),
    );
  }
}