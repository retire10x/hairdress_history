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
    return Column(
      children: [
        // 고객 정보 섹션
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(
              bottom: BorderSide(color: Colors.blue[200]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: Colors.blue[900],
                    ),
                    const SizedBox(width: 8),
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
                      const SizedBox(width: 12),
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        customer.phone!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                    if (customer.memo != null && customer.memo!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.note,
                        size: 16,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
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
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: onAddRecord,
                icon: const Icon(Icons.add),
                label: const Text('기록 추가'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ],
          ),
        ),
        // 헤더
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: const Row(
            children: [
              Text(
                '서비스 기록',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        // 타임라인
        Expanded(
          child: records.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '서비스 기록이 없습니다',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '위의 기록 추가 버튼을 눌러주세요',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    final isLast = index == records.length - 1;

                    return _TimelineItem(
                      record: record,
                      isLast: isLast,
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
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TimelineItem({
    required this.record,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final timeFormat = DateFormat('HH:mm');
    final numberFormat = NumberFormat('#,###원');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 타임라인 라인
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 12,
                color: Colors.blue[200],
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // 기록 내용
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
                children: [
                  // 날짜/시간
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${dateFormat.format(record.serviceDate)} ${timeFormat.format(record.serviceDate)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // 시술 내용
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Icon(
                          Icons.content_cut,
                          size: 14,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            record.serviceContent,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (record.productName != null &&
                      record.productName!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 14,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              record.productName!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  // 결제 타입
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPaymentColor(record.paymentType),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      record.paymentType.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 금액
                  Text(
                    numberFormat.format(record.amount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  if (record.memo != null && record.memo!.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.note,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                  ],
                  const SizedBox(width: 8),
                  // 수정/삭제 버튼
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    iconSize: 16,
                    color: Colors.blue[700],
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    iconSize: 16,
                    color: Colors.red[700],
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
