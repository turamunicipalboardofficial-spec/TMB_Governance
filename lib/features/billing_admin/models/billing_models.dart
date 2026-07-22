/// Market model returned by GET /api/billing/markets
class MarketModel {
  final String marketId;
  final String marketName;

  MarketModel({required this.marketId, required this.marketName});

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      marketId: json['market_id']?.toString() ?? '',
      marketName: json['market_name'] ?? '',
    );
  }
}

/// A single billing transaction (bill) as returned by the API.
class BillModel {
  final int id;
  final int? electricityReadingId;
  final String marketId;
  final String shopNo;
  final String? billMonth;
  final String? generatedAt;
  final String? dueDate;
  final num rentAmount;
  final num electricityAmount;
  final num lateFee;
  final num totalAmount;
  final num paidAmount;
  final num balanceDue;
  final String status; // UNPAID, PARTIAL, PAID
  final bool isOverdue;
  // Present only on generate-bills response items
  final String? marketName;
  final String? shopName;
  final String? ownerName;
  final num? previousOutstanding;
  final num? amountPayable;

  BillModel({
    required this.id,
    this.electricityReadingId,
    required this.marketId,
    required this.shopNo,
    this.billMonth,
    this.generatedAt,
    this.dueDate,
    required this.rentAmount,
    required this.electricityAmount,
    required this.lateFee,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.status,
    required this.isOverdue,
    this.marketName,
    this.shopName,
    this.ownerName,
    this.previousOutstanding,
    this.amountPayable,
  });

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'] ?? 0,
      electricityReadingId: json['electricity_reading_id'],
      marketId: json['market_id']?.toString() ?? '',
      shopNo: json['shop_no']?.toString() ?? '',
      billMonth: json['bill_month'],
      generatedAt: json['generated_at'],
      dueDate: json['due_date'],
      rentAmount: json['rent_amount'] ?? 0,
      electricityAmount: json['electricity_amount'] ?? 0,
      lateFee: json['late_fee'] ?? 0,
      totalAmount: json['total_amount'] ?? 0,
      paidAmount: json['paid_amount'] ?? 0,
      balanceDue: json['balance_due'] ?? 0,
      status: json['status'] ?? 'UNPAID',
      isOverdue: json['is_overdue'] ?? false,
      marketName: json['market_name'],
      shopName: json['shop_name'],
      ownerName: json['owner_name'],
      previousOutstanding: json['previous_outstanding'],
      amountPayable: json['amount_payable'],
    );
  }
}

/// Response of GET /api/billing/shops/{marketId}/{shopNo}/bills
class ShopBillsResult {
  final String marketId;
  final String? marketName;
  final String shopNo;
  final String? shopName;
  final String? ownerName;
  final num monthlyRent;
  final BillsSummary summary;
  final List<BillModel> bills;

  ShopBillsResult({
    required this.marketId,
    this.marketName,
    required this.shopNo,
    this.shopName,
    this.ownerName,
    required this.monthlyRent,
    required this.summary,
    required this.bills,
  });

  factory ShopBillsResult.fromJson(Map<String, dynamic> json) {
    return ShopBillsResult(
      marketId: json['market_id']?.toString() ?? '',
      marketName: json['market_name'],
      shopNo: json['shop_no']?.toString() ?? '',
      shopName: json['shop_name'],
      ownerName: json['owner_name'],
      monthlyRent: json['monthly_rent'] ?? 0,
      summary: BillsSummary.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      bills: (json['bills'] as List? ?? [])
          .map((e) => BillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class BillsSummary {
  final int totalBills;
  final num totalBilledAmount;
  final num totalPaidAmount;
  final num totalOutstandingAmount;

  BillsSummary({
    required this.totalBills,
    required this.totalBilledAmount,
    required this.totalPaidAmount,
    required this.totalOutstandingAmount,
  });

  factory BillsSummary.fromJson(Map<String, dynamic> json) {
    return BillsSummary(
      totalBills: json['total_bills'] ?? 0,
      totalBilledAmount: json['total_billed_amount'] ?? 0,
      totalPaidAmount: json['total_paid_amount'] ?? 0,
      totalOutstandingAmount: json['total_outstanding_amount'] ?? 0,
    );
  }
}

/// Response of GET /api/billing/shops/{marketId}/{shopNo}/outstanding
class OutstandingResult {
  final String marketId;
  final String? marketName;
  final String shopNo;
  final String? shopName;
  final num outstandingAmount;
  final num overdueAmount;
  final int openBillsCount;
  final List<BillModel> openBills;

  OutstandingResult({
    required this.marketId,
    this.marketName,
    required this.shopNo,
    this.shopName,
    required this.outstandingAmount,
    required this.overdueAmount,
    required this.openBillsCount,
    required this.openBills,
  });

  factory OutstandingResult.fromJson(Map<String, dynamic> json) {
    return OutstandingResult(
      marketId: json['market_id']?.toString() ?? '',
      marketName: json['market_name'],
      shopNo: json['shop_no']?.toString() ?? '',
      shopName: json['shop_name'],
      outstandingAmount: json['outstanding_amount'] ?? 0,
      overdueAmount: json['overdue_amount'] ?? 0,
      openBillsCount: json['open_bills_count'] ?? 0,
      openBills: (json['open_bills'] as List? ?? [])
          .map((e) => BillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Response of POST /api/billing/generate-monthly-bills
class GenerateBillsResult {
  final String billMonth;
  final String dueDate;
  final int generatedCount;
  final List<BillModel> bills;

  GenerateBillsResult({
    required this.billMonth,
    required this.dueDate,
    required this.generatedCount,
    required this.bills,
  });

  factory GenerateBillsResult.fromJson(Map<String, dynamic> json) {
    return GenerateBillsResult(
      billMonth: json['bill_month'] ?? '',
      dueDate: json['due_date'] ?? '',
      generatedCount: json['generated_count'] ?? 0,
      bills: (json['bills'] as List? ?? [])
          .map((e) => BillModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single row entry for the manual "generate bills" form.
class BillRowInput {
  String marketId;
  String shopNo;
  double electricityAmount;

  BillRowInput({
    this.marketId = '',
    this.shopNo = '',
    this.electricityAmount = 0,
  });

  Map<String, dynamic> toJson() => {
        'market_id': marketId,
        'shop_no': shopNo,
        'electricity_amount': electricityAmount,
      };
}

/// Result of POST /api/billing/payments/update-status
class PaymentSyncResult {
  final String message;
  final BillModel bill;
  final PaymentSummary payment;

  PaymentSyncResult({
    required this.message,
    required this.bill,
    required this.payment,
  });

  factory PaymentSyncResult.fromJson(Map<String, dynamic> json) {
    return PaymentSyncResult(
      message: json['message'] ?? '',
      bill: BillModel.fromJson(json['bill'] as Map<String, dynamic>),
      payment: PaymentSummary.fromJson(json['payment'] as Map<String, dynamic>),
    );
  }
}

class PaymentSummary {
  final int id;
  final String? orderId;
  final String? paymentId;
  final num amount;
  final String status;
  final int? billId;
  final String? marketId;
  final String? shopNo;
  final String? paymentRemarks;
  final String? updatedAt;

  PaymentSummary({
    required this.id,
    this.orderId,
    this.paymentId,
    required this.amount,
    required this.status,
    this.billId,
    this.marketId,
    this.shopNo,
    this.paymentRemarks,
    this.updatedAt,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      id: json['id'] ?? 0,
      orderId: json['order_id'],
      paymentId: json['payment_id'],
      amount: json['amount'] ?? 0,
      status: json['status'] ?? '',
      billId: json['bill_id'],
      marketId: json['market_id'],
      shopNo: json['shop_no'],
      paymentRemarks: json['payment_remarks'],
      updatedAt: json['updated_at'],
    );
  }
}
