class FormListItem {
  final String applicationId;
  final String applicationSubmittedAt;
  final String applicationFor;
  final String status;
  final int formNumber;
  final int formId;
  final String? payment;
  final String? paymentStatus;
  final String? paymentAmount;
  final Map<String, dynamic>? form;
  final Map<String, dynamic>? counts;

  FormListItem({
    required this.applicationId,
    required this.applicationSubmittedAt,
    required this.applicationFor,
    required this.status,
    this.formNumber = 0,
    required this.formId,
    this.payment,
    this.paymentStatus,
    this.paymentAmount,
    this.form,
    this.counts,
  });

  factory FormListItem.fromJson(Map<String, dynamic> json) => FormListItem(
    applicationId: json['application_id'] ?? '',
    applicationSubmittedAt: json['application_submited_at'] ?? '',
    applicationFor: json['application_for'] ?? '',
    status: json['status'] ?? 'Pending',
    formNumber: json['formNumber'] ?? 0,
    formId: json['form_id'] ?? 0,
    payment: json['payment'],
    paymentStatus: json['payment_status'],
    paymentAmount: json['payment_amount']?.toString(),
    form: json['form'] is Map<String, dynamic> ? json['form'] : null,
    counts: json['counts'] is Map<String, dynamic> ? json['counts'] : null,
  );

  /// Convenience getters for backward compatibility
  String get ownerName => form?['owner_name'] ?? '';
  String get ownerPhone => form?['owner_phone'] ?? '';
}