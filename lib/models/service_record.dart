enum PaymentType {
  cash('현금'),
  card('카드'),
  transfer('송금');

  const PaymentType(this.label);
  final String label;
}

class ServiceRecord {
  final int? id;
  final int customerId;
  final DateTime serviceDate;
  final String serviceContent;
  final String? productName;
  final PaymentType paymentType;
  final int amount;
  final String? memo;
  final DateTime createdAt;

  ServiceRecord({
    this.id,
    required this.customerId,
    required this.serviceDate,
    required this.serviceContent,
    this.productName,
    required this.paymentType,
    required this.amount,
    this.memo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'service_date': serviceDate.toIso8601String(),
      'service_content': serviceContent,
      'product_name': productName,
      'payment_type': paymentType.name,
      'amount': amount,
      'memo': memo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int,
      serviceDate: DateTime.parse(map['service_date'] as String),
      serviceContent: map['service_content'] as String,
      productName: map['product_name'] as String?,
      paymentType: PaymentType.values.firstWhere(
        (e) => e.name == map['payment_type'] as String,
      ),
      amount: map['amount'] as int,
      memo: map['memo'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
