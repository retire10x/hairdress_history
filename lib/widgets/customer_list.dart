import 'package:flutter/material.dart';
import '../models/customer.dart';

enum SortType {
  name('이름'),
  serviceDate('서비스일'),
  amount('금액');

  const SortType(this.label);
  final String label;
}

enum SortOrder {
  asc('오름차순'),
  desc('내림차순');

  const SortOrder(this.label);
  final String label;
}

class CustomerList extends StatelessWidget {
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final Function(Customer) onCustomerSelected;
  final VoidCallback onAddCustomer;
  final Function(Customer) onEditCustomer;
  final Function(Customer) onDeleteCustomer;
  final SortType sortType;
  final SortOrder sortOrder;
  final Function(SortType, SortOrder) onSortChanged;

  const CustomerList({
    super.key,
    required this.customers,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onAddCustomer,
    required this.onEditCustomer,
    required this.onDeleteCustomer,
    this.sortType = SortType.name,
    this.sortOrder = SortOrder.asc,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                bottom: BorderSide(color: Colors.blue[200]!),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '고객 목록',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: onAddCustomer,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('추가', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 정렬 옵션
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      '정렬: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // 정렬 타입 선택
                    ...SortType.values.map((type) {
                      final isSelected = sortType == type;
                      return SizedBox(
                        height: 28,
                        child: ChoiceChip(
                          label: Text(type.label),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              onSortChanged(type, sortOrder);
                            }
                          },
                          selectedColor: Colors.blue[200],
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.blue[900] : Colors.grey[700],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          showCheckmark: false,
                        ),
                      );
                    }),
                    // 정렬 순서 선택
                    SizedBox(
                      height: 28,
                      child: TextButton(
                        onPressed: () {
                          final newOrder = sortOrder == SortOrder.asc
                              ? SortOrder.desc
                              : SortOrder.asc;
                          onSortChanged(sortType, newOrder);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          minimumSize: const Size(0, 28),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          sortOrder == SortOrder.asc ? '↑' : '↓',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 고객 리스트
          Expanded(
            child: customers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '고객이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '오른쪽 상단의 추가 버튼을 눌러주세요',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      final isSelected = selectedCustomer?.id == customer.id;

                      return InkWell(
                        onTap: () => onCustomerSelected(customer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      customer.name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.blue[900]
                                            : Colors.grey[900],
                                      ),
                                    ),
                                    if (customer.phone != null &&
                                        customer.phone!.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(
                                        '• ${customer.phone!}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // 수정/삭제 버튼
                              IconButton(
                                onPressed: () => onEditCustomer(customer),
                                icon: const Icon(Icons.edit),
                                iconSize: 18,
                                color: Colors.blue[700],
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                              IconButton(
                                onPressed: () => onDeleteCustomer(customer),
                                icon: const Icon(Icons.delete),
                                iconSize: 18,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
