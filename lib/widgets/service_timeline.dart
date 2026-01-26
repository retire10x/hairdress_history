import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_record.dart';
import '../models/customer.dart';

class ServiceTimeline extends StatelessWidget {
  final Customer customer;
  final List<ServiceRecord> records;
  final VoidCallback onAddRecord;
  final Function(ServiceRecord) onEditRecord;
  final Function(ServiceRecord) onDeleteRecord;

  const ServiceTimeline({
    super.key,
    required this.customer,
    required this.records,
    required this.onAddRecord,
    required this.onEditRecord,
    required this.onDeleteRecord,
  });

  @override
  Widget build(BuildContext context) {
    // 서비스일 최근순으로 정렬 (내림차순)
    final sortedRecords = List<ServiceRecord>.from(records)
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));

    // 총 서비스 금액 계산
    final totalAmount = sortedRecords.fold<int>(
      0,
      (sum, record) => sum + record.amount,
    );
    final formattedTotal = NumberFormat('#,###').format(totalAmount);

    // 최초일/최종일 계산
    DateTime? firstDate;
    DateTime? lastDate;
    if (sortedRecords.isNotEmpty) {
      final dates = sortedRecords.map((r) => r.serviceDate).toList();
      dates.sort();
      firstDate = dates.first;
      lastDate = dates.last;
    }

    // 날짜 포맷 (숫자만: YYYYMMDD)
    String formatDate(DateTime date) {
      return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    }

    return Column(
      children: [
        // 고객 정보 섹션
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.blue[900]),
                    const SizedBox(width: 6),
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    if (customer.phone != null &&
                        customer.phone!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.phone, size: 14, color: Colors.grey[700]),
                      const SizedBox(width: 3),
                      Text(
                        customer.phone!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                    if (customer.memo != null && customer.memo!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.note, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          customer.memo!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // 최초일/최종일 및 합계 표시
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (firstDate != null && lastDate != null) ...[
                    Text(
                      '${formatDate(firstDate)}/${formatDate(lastDate)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    '합계: $formattedTotal원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                onPressed: onAddRecord,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('기록 추가', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  minimumSize: const Size(0, 24),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
        // 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: const Row(
            children: [
              Text(
                '서비스 기록',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        // 타임라인
        Expanded(
          child: sortedRecords.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        '서비스 기록이 없습니다',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '위의 기록 추가 버튼을 눌러주세요',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: sortedRecords.length,
                  itemBuilder: (context, index) {
                    final record = sortedRecords[index];

                    return _TimelineItem(
                      record: record,
                      onEdit: () => onEditRecord(record),
                      onDelete: () => onDeleteRecord(record),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ServiceRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimelineItem({
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final numberFormat = NumberFormat('#,###원');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 날짜 (고정 너비 100px)
                SizedBox(
                  width: 100,
                  child: Tooltip(
                    message: dateFormat.format(record.serviceDate),
                    child: Text(
                      dateFormat.format(record.serviceDate),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                // 서비스 내용 (고정 너비 150px)
                SizedBox(
                  width: 150,
                  child: Tooltip(
                    message: record.serviceContent,
                    child: Text(
                      record.serviceContent,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 3),
                // 제품명 (고정 너비 100px, 선택적)
                SizedBox(
                  width: 100,
                  child:
                      record.productName != null &&
                          record.productName!.isNotEmpty
                      ? Tooltip(
                          message: record.productName!,
                          child: Text(
                            '/ ${record.productName!}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 3),
                // 결제 타입 (고정 너비 60px)
                SizedBox(
                  width: 60,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentColor(record.paymentType),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      record.paymentType.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // 금액 (고정 너비 100px)
                SizedBox(
                  width: 100,
                  child: Tooltip(
                    message: numberFormat.format(record.amount),
                    child: Text(
                      numberFormat.format(record.amount),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                Container(width: 30),
                // 메모 (고정 너비 100px, 선택적, 금액 우측)
                SizedBox(
                  width: 100,
                  child: record.memo != null && record.memo!.isNotEmpty
                      ? Tooltip(
                          message: record.memo!,
                          child: Text(
                            record.memo!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          // 수정/삭제 버튼
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            iconSize: 16,
            color: Colors.blue[700],
            padding: const EdgeInsets.all(1),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            iconSize: 16,
            color: Colors.red[700],
            padding: const EdgeInsets.all(1),
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Color _getPaymentColor(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Colors.green;
      case PaymentType.card:
        return Colors.orange;
      case PaymentType.transfer:
        return Colors.purple;
    }
  }
}
