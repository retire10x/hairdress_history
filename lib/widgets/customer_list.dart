import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../database/database_helper.dart';

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

class CustomerList extends StatefulWidget {
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
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<int>? _serviceDateCustomerIds; // 날짜 검색 시 사용할 고객 ID 목록

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 검색어가 날짜 형식인지 확인하고 DateTime으로 변환
  DateTime? _parseDate(String query) {
    // 다양한 날짜 형식 시도
    final dateFormats = [
      'yyyy-MM-dd',
      'yyyyMMdd',
      'yyyy/MM/dd',
      'yyyy.MM.dd',
      'MM-dd',
      'MM/dd',
      'MMdd',
    ];

    for (final format in dateFormats) {
      try {
        final date = DateFormat(format).parse(query);
        // 연도가 없으면 현재 연도 사용
        if (!format.contains('yyyy')) {
          final now = DateTime.now();
          return DateTime(now.year, date.month, date.day);
        }
        return date;
      } catch (e) {
        // 다음 형식 시도
        continue;
      }
    }
    return null;
  }

  /// 날짜 검색을 위한 고객 ID 목록 로드
  Future<void> _loadServiceDateCustomerIds(DateTime date) async {
    try {
      final ids = await _db.getCustomerIdsByServiceDate(date);
      if (mounted) {
        setState(() {
          _serviceDateCustomerIds = ids;
        });
      }
    } catch (e) {
      debugPrint('서비스일 검색 오류: $e');
      if (mounted) {
        setState(() {
          _serviceDateCustomerIds = [];
        });
      }
    }
  }

  List<Customer> get _filteredCustomers {
    if (_searchQuery.isEmpty) {
      return widget.customers;
    }

    final query = _searchQuery.trim();

    // 날짜 형식인지 확인
    final date = _parseDate(query);
    if (date != null && _serviceDateCustomerIds != null) {
      // 날짜 검색: 해당 날짜에 서비스 기록이 있는 고객만 필터링
      return widget.customers.where((customer) {
        return customer.id != null &&
            _serviceDateCustomerIds!.contains(customer.id!);
      }).toList();
    }

    // 이름/전화번호 검색
    final queryLower = query.toLowerCase();
    return widget.customers.where((customer) {
      final name = customer.name.toLowerCase();
      final phone = customer.phone?.toLowerCase() ?? '';
      return name.contains(queryLower) || phone.contains(queryLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '고객 목록',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_filteredCustomers.length}명',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: widget.onAddCustomer,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('추가', style: TextStyle(fontSize: 12)),
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
                const SizedBox(height: 2),
                // 검색창
                Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                    decoration: InputDecoration(
                      hintText: '이름/전화번호/서비스일 검색',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 12,
                        color: Colors.grey,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Icon(
                                Icons.clear,
                                size: 12,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) async {
                      setState(() {
                        _searchQuery = value;
                        // 날짜 검색이 아닌 경우 고객 ID 목록 초기화
                        final date = _parseDate(value.trim());
                        if (date == null) {
                          _serviceDateCustomerIds = null;
                        } else {
                          // 날짜 검색인 경우 고객 ID 목록 로드
                          _loadServiceDateCustomerIds(date);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 2),
                // 정렬 옵션
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 정렬 타입 선택
                    ...SortType.values.expand((type) {
                      final isSelected = widget.sortType == type;
                      return [
                        SizedBox(
                          height: 24,
                          child: ChoiceChip(
                            label: Text(
                              type.label,
                              textAlign: TextAlign.center,
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                widget.onSortChanged(type, widget.sortOrder);
                              }
                            },
                            selectedColor: Colors.blue[200],
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.blue[900]
                                  : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              height: 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 0,
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            showCheckmark: false,
                            labelPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ];
                    }),
                    // 정렬 순서 선택
                    SizedBox(
                      height: 24,
                      child: TextButton(
                        onPressed: () {
                          final newOrder = widget.sortOrder == SortOrder.asc
                              ? SortOrder.desc
                              : SortOrder.asc;
                          widget.onSortChanged(widget.sortType, newOrder);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 0,
                          ),
                          minimumSize: const Size(0, 24),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          widget.sortOrder == SortOrder.asc ? '↑' : '↓',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
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
            child: widget.customers.isEmpty
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
                : _filteredCustomers.isEmpty
                ? Center(
                    child: Text(
                      '검색 결과가 없습니다',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final customer = _filteredCustomers[index];
                      final isSelected =
                          widget.selectedCustomer?.id == customer.id;

                      return InkWell(
                        onTap: () => widget.onCustomerSelected(customer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 1,
                            vertical: 0,
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
                                      const SizedBox(width: 3),
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
                              const SizedBox(width: 5),
                              // 수정/삭제 버튼
                              IconButton(
                                onPressed: () =>
                                    widget.onEditCustomer(customer),
                                icon: const Icon(Icons.edit),
                                iconSize: 16,
                                color: Colors.blue[700],
                                padding: const EdgeInsets.all(1),
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    widget.onDeleteCustomer(customer),
                                icon: const Icon(Icons.delete),
                                iconSize: 16,
                                color: Colors.red[700],
                                padding: const EdgeInsets.all(1),
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
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
