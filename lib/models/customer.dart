class Customer {
  final int? id;
  final String name;
  final String? phone;
  final String? memo;
  final DateTime createdAt;

  Customer({
    this.id,
    required this.name,
    this.phone,
    this.memo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'memo': memo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      memo: map['memo'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Customer copyWith({
    int? id,
    String? name,
    String? phone,
    String? memo,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
