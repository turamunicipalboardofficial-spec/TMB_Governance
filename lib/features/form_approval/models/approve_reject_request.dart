class ApproveRejectRequest {
  final String formId;
  final String applicationId;
  final String approver;
  final String status;

  ApproveRejectRequest({
    required this.formId,
    required this.applicationId,
    required this.approver,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'form_id': formId,
        'application_id': applicationId,
        'approver': approver,
        'status': status,
      };
}