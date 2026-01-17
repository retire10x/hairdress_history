import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomerList extends StatelessWidget {
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final Function(Customer) onCustomerSelected;
  final VoidCallback onAddCustomer;
  final Function(Customer) onEditCustomer;
  final Function(Customer) onDeleteCustomer;

  const CustomerList({
    super.key,
    required this.customers,
    this.selectedCustomer,
    required this.onCustomerSelected,
    required this.onAddCustomer,
    required this.onEditCustomer,
    required this.onDeleteCustomer,
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
            child: Row(
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
                  icon: const Icon(Icons.add),
                  label: const Text('추가'),
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
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[100] : Colors.white,
                            borderRadius: BorderRadius.circular(8),
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.blue[900]
                                            : Colors.grey[900],
                                      ),
                                    ),
                                    if (customer.phone != null &&
                                        customer.phone!.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${customer.phone!}',
                                        style: TextStyle(
                                          fontSize: 14,
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
                                iconSize: 20,
                                color: Colors.blue[700],
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                              IconButton(
                                onPressed: () => onDeleteCustomer(customer),
                                icon: const Icon(Icons.delete),
                                iconSize: 20,
                                color: Colors.red[700],
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
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
