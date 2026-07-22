class HoldingTaxModel {
  final int id;
  final int? slNo;
  final int? wardNo;
  final String holdingNo;
  final String? name;
  final String? address;
  final String taxType; // house | commercial
  final num? taxRate;
  final int? lastPaymentYear;
  final int? currentYear;
  final int? countYear;
  final num? amountPayable;
  final String paymentStatus; // unpaid | paid
  final String? paymentDate;
  final num? paidAmount;
  final String? paymentRemarks;
  final String? createdAt;
  final String? updatedAt;

  HoldingTaxModel({
    required this.id,
    this.slNo,
    this.wardNo,
    required this.holdingNo,
    this.name,
    this.address,
    required this.taxType,
    this.taxRate,
    this.lastPaymentYear,
    this.currentYear,
    this.countYear,
    this.amountPayable,
    required this.paymentStatus,
    this.paymentDate,
    this.paidAmount,
    this.paymentRemarks,
    this.createdAt,
    this.updatedAt,
  });

  factory HoldingTaxModel.fromJson(Map<String, dynamic> json) {
    // Laravel's `decimal:2` cast serializes to a STRING in JSON
    // (e.g. "200.00"), not a number. Parse safely regardless of whether
    // the API sends a string, int, or double.
    num? parseNum(dynamic value) {
      if (value == null) return null;
      if (value is num) return value;
      return num.tryParse(value.toString());
    }

    return HoldingTaxModel(
      id: json['id'] ?? 0,
      slNo: json['sl_no'],
      wardNo: json['ward_no'],
      holdingNo: json['holding_no'] ?? '',
      name: json['name'],
      address: json['address'],
      taxType: json['tax_type'] ?? 'house',
      taxRate: parseNum(json['tax_rate']),
      lastPaymentYear: json['last_payment_year'],
      currentYear: json['current_year'],
      countYear: json['count_year'],
      amountPayable: parseNum(json['amount_payable']),
      paymentStatus: json['payment_status'] ?? 'unpaid',
      paymentDate: json['payment_date'],
      paidAmount: parseNum(json['paid_amount']),
      paymentRemarks: json['payment_remarks'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  bool get isPaid => paymentStatus == 'paid';
  bool get isCommercial => taxType == 'commercial';
}

/// Lightweight row used for search/autocomplete results
/// (only holding_no, name, address, tax_type are returned by /search).
class HoldingTaxSearchItem {
  final String holdingNo;
  final String? name;
  final String? address;
  final String taxType;

  HoldingTaxSearchItem({
    required this.holdingNo,
    this.name,
    this.address,
    required this.taxType,
  });

  factory HoldingTaxSearchItem.fromJson(Map<String, dynamic> json) {
    return HoldingTaxSearchItem(
      holdingNo: json['holding_no'] ?? '',
      name: json['name'],
      address: json['address'],
      taxType: json['tax_type'] ?? 'house',
    );
  }
}

class HoldingTaxStats {
  final int total;
  final int paid;
  final int unpaid;

  HoldingTaxStats({required this.total, required this.paid, required this.unpaid});

  factory HoldingTaxStats.fromJson(Map<String, dynamic> json) {
    return HoldingTaxStats(
      total: json['total'] ?? 0,
      paid: json['paid'] ?? 0,
      unpaid: json['unpaid'] ?? 0,
    );
  }
}
