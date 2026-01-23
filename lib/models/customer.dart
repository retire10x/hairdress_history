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
    // SQLite는 컬럼 이름을 소문자로 반환할 수 있으므로 대소문자 구분 없이 처리
    final createdAtStr = map['created_at'] ?? map['created_At'] ?? map['CREATED_AT'];
    if (createdAtStr == null) {
      throw Exception('created_at 필드가 없습니다. 데이터: $map');
    }
    
    DateTime createdAt;
    try {
      createdAt = DateTime.parse(createdAtStr.toString());
    } catch (e) {
      throw Exception('created_at 파싱 실패: $createdAtStr, 오류: $e');
    }
    
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String? ?? map['Name'] as String? ?? '',
      phone: map['phone'] as String? ?? map['Phone'] as String?,
      memo: map['memo'] as String? ?? map['Memo'] as String?,
      createdAt: createdAt,
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
