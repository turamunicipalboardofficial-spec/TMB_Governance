class FormType {
  final int id;
  final String name;
  final String status;

  const FormType({
    required this.id,
    required this.name,
    required this.status,
  });

  factory FormType.fromJson(Map<String, dynamic> json) {
    return FormType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
