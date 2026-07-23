/// A single payment record returned by GET /api/dashboard/admin/payment-history
class PaymentHistoryItem {
  final int id;
  final String? formId;
  final int? formTypeId;
  final num amount;
  final String status; // success | failed | pending
  final String? transactionId;
  final String? orderId;
  final int? userId;
  final String userName;
  final String? paymentDate;

  PaymentHistoryItem({
    required this.id,
    this.formId,
    this.formTypeId,
    required this.amount,
    required this.status,
    this.transactionId,
    this.orderId,
    this.userId,
    required this.userName,
    this.paymentDate,
  });

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    // Laravel decimal casts can serialize as strings; parse safely.
    num parseAmount(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.tryParse(value.toString()) ?? 0;
    }

    return PaymentHistoryItem(
      id: json['id'] ?? 0,
      formId: json['form_id']?.toString(),
      formTypeId: json['form_type'] is int
          ? json['form_type']
          : int.tryParse(json['form_type']?.toString() ?? ''),
      amount: parseAmount(json['amount']),
      status: json['status'] ?? 'pending',
      transactionId: json['transaction_id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? 'Unknown',
      paymentDate: json['payment_date'],
    );
  }
}

class PaymentHistoryPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;

  PaymentHistoryPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
  });

  factory PaymentHistoryPagination.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryPagination(
      total: json['total'] ?? 0,
      perPage: json['per_page'] ?? 15,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class PaymentHistoryResult {
  final List<PaymentHistoryItem> payments;
  final PaymentHistoryPagination pagination;

  PaymentHistoryResult({required this.payments, required this.pagination});

  factory PaymentHistoryResult.fromJson(Map<String, dynamic> json) {
    final paymentsJson = json['payments'] as List? ?? [];
    return PaymentHistoryResult(
      payments: paymentsJson
          .map((e) => PaymentHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaymentHistoryPagination.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
