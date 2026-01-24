import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';
import '../models/service_record.dart';
import '../widgets/customer_list.dart';
import '../widgets/service_timeline.dart';
import '../widgets/add_customer_dialog.dart';
import '../widgets/add_record_dialog.dart';
import '../constants/app_config.dart';
import '../services/app_title_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  List<ServiceRecord> _serviceRecords = [];
  bool _isLoading = true;
  SortType _sortType = SortType.name;
  SortOrder _sortOrder = SortOrder.asc;
  String _appTitle = AppConfig.appName; // 기본값

  @override
  void initState() {
    super.initState();
    _loadAppTitle();
    _loadCustomers();
  }

  /// 외부 txt 파일에서 AppBar 제목을 읽어옵니다
  Future<void> _loadAppTitle() async {
    try {
      final title = await AppTitleService.getAppTitle(
        defaultTitle: AppConfig.appName,
      );
      if (mounted) {
        setState(() {
          _appTitle = title;
        });
      }
    } catch (e) {
      // 오류 발생 시 기본값 사용
      debugPrint('Failed to load app title: $e');
    }
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // SortType enum의 name을 데이터베이스 쿼리 형식으로 변환
      String sortByValue;
      switch (_sortType) {
        case SortType.name:
          sortByValue = 'name';
          break;
        case SortType.serviceDate:
          sortByValue = 'service_date';
          break;
        case SortType.amount:
          sortByValue = 'amount';
          break;
      }

      final customers = await _db.getAllCustomers(
        sortBy: sortByValue,
        order: _sortOrder.name.toUpperCase(),
      );
      setState(() {
        _customers = customers;
        _isLoading = false;
      });

      // 첫 번째 고객이 있으면 자동 선택
      if (_customers.isNotEmpty && _selectedCustomer == null) {
        _selectCustomer(_customers.first);
      }
    } catch (e, stackTrace) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('고객 목록을 불러오는 중 오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('고객 목록 불러오기 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }

  void _onSortChanged(SortType sortType, SortOrder sortOrder) {
    setState(() {
      _sortType = sortType;
      _sortOrder = sortOrder;
    });
    _loadCustomers();
  }

  Future<void> _clearAllData() async {
    // 비밀번호 입력 다이얼로그
    final passwordController = TextEditingController();
    final passwordResult = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 초기화'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('모든 고객과 서비스 기록이 삭제됩니다.\n비밀번호를 입력하세요.'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                border: OutlineInputBorder(),
              ),
              obscureText: false,
              keyboardType: TextInputType.phone,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              if (passwordController.text.trim() == '01027870380') {
                Navigator.of(context).pop(true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('비밀번호가 일치하지 않습니다.'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );

    if (passwordResult == true) {
      // 최종 확인
      if (!mounted) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('최종 확인'),
          content: const Text('정말로 모든 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('삭제'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        setState(() {
          _isLoading = true;
        });

        try {
          await _db.clearAllData();
          setState(() {
            _customers = [];
            _selectedCustomer = null;
            _serviceRecords = [];
            _isLoading = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('모든 데이터가 삭제되었습니다.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (e, stackTrace) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('데이터 초기화 중 오류가 발생했습니다: $e'),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.red,
              ),
            );
          }
          debugPrint('데이터 초기화 오류: $e');
          debugPrint('스택 트레이스: $stackTrace');
        }
      }
    }
  }

  Future<void> _selectCustomer(Customer customer) async {
    setState(() {
      _selectedCustomer = customer;
    });

    try {
      final records = await _db.getServiceRecordsByCustomer(customer.id!);
      setState(() {
        _serviceRecords = records;
      });
    } catch (e, stackTrace) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('서비스 기록을 불러오는 중 오류가 발생했습니다: $e'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('서비스 기록 불러오기 오류: $e');
      debugPrint('스택 트레이스: $stackTrace');
    }
  }

  Future<void> _showAddCustomerDialog() async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    );

    if (result != null) {
      try {
        await _db.insertCustomer(result);
        await _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('고객이 추가되었습니다')));
        }
      } catch (e, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('고객 추가 중 오류가 발생했습니다: $e'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: '자세히',
                textColor: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('오류 상세'),
                      content: SingleChildScrollView(
                        child: Text('오류: $e\n\n스택 트레이스:\n$stackTrace'),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        }
        // 디버그를 위해 콘솔에도 출력
        debugPrint('고객 추가 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    }
  }

  Future<void> _showEditCustomerDialog(Customer customer) async {
    final result = await showDialog<Customer>(
      context: context,
      builder: (context) => AddCustomerDialog(customer: customer),
    );

    if (result != null) {
      try {
        await _db.updateCustomer(result);
        await _loadCustomers();
        // 수정된 고객이 선택되어 있으면 다시 선택
        if (_selectedCustomer?.id == result.id) {
          await _selectCustomer(result);
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('고객 정보가 수정되었습니다')));
        }
      } catch (e, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('고객 수정 중 오류가 발생했습니다: $e'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('고객 수정 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    }
  }

  Future<void> _showDeleteCustomerDialog(Customer customer) async {
    // 서비스 기록이 있는지 확인
    final hasRecords = await _db.hasServiceRecords(customer.id!);

    if (hasRecords) {
      // 서비스 기록이 있으면 삭제 불가
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('삭제 불가'),
            content: Text(
              '${customer.name} 고객은 서비스 기록이 있어 삭제할 수 없습니다.\n먼저 모든 서비스 기록을 삭제한 후 고객을 삭제해주세요.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 서비스 기록이 없으면 삭제 확인 다이얼로그 표시
    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('고객 삭제'),
        content: Text('${customer.name} 고객을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _db.deleteCustomer(customer.id!);
        // 삭제된 고객이 선택되어 있으면 선택 해제
        if (_selectedCustomer?.id == customer.id) {
          setState(() {
            _selectedCustomer = null;
            _serviceRecords = [];
          });
        }
        await _loadCustomers();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('고객이 삭제되었습니다')));
        }
      } catch (e, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('고객 삭제 중 오류가 발생했습니다: $e'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('고객 삭제 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    }
  }

  Future<void> _showAddRecordDialog() async {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 고객을 선택해주세요')));
      return;
    }

    final result = await showDialog<ServiceRecord>(
      context: context,
      builder: (context) => AddRecordDialog(customerId: _selectedCustomer!.id!),
    );

    if (result != null) {
      try {
        await _db.insertServiceRecord(result);
        await _selectCustomer(_selectedCustomer!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('서비스 기록이 추가되었습니다')));
        }
      } catch (e, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('기록 추가 중 오류가 발생했습니다: $e'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('기록 추가 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    }
  }

  Future<void> _showEditRecordDialog(ServiceRecord record) async {
    final result = await showDialog<ServiceRecord>(
      context: context,
      builder: (context) =>
          AddRecordDialog(customerId: record.customerId, record: record),
    );

    if (result != null) {
      try {
        await _db.updateServiceRecord(result);
        await _selectCustomer(_selectedCustomer!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('서비스 기록이 수정되었습니다')));
        }
      } catch (e, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('기록 수정 중 오류가 발생했습니다: $e'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('기록 수정 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    }
  }

  Future<void> _showDeleteRecordDialog(ServiceRecord record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('서비스 기록 삭제'),
        content: const Text('이 서비스 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _db.deleteServiceRecord(record.id!);
        await _selectCustomer(_selectedCustomer!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('서비스 기록이 삭제되었습니다')));
        }
      } catch (e, stackTrace) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('기록 삭제 중 오류가 발생했습니다: $e'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.red,
            ),
          );
        }
        debugPrint('기록 삭제 오류: $e');
        debugPrint('스택 트레이스: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_appTitle),
        toolbarHeight: 40,
        titleSpacing: 16,
        actionsIconTheme: const IconThemeData(size: 18),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, size: 18),
            tooltip: '데이터 초기화',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: _clearAllData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // 왼쪽: 고객 목록 (고정 너비)
                SizedBox(
                  width: 300,
                  child: CustomerList(
                    customers: _customers,
                    selectedCustomer: _selectedCustomer,
                    onCustomerSelected: _selectCustomer,
                    onAddCustomer: _showAddCustomerDialog,
                    onEditCustomer: _showEditCustomerDialog,
                    onDeleteCustomer: _showDeleteCustomerDialog,
                    sortType: _sortType,
                    sortOrder: _sortOrder,
                    onSortChanged: _onSortChanged,
                  ),
                ),
                // 구분선
                Container(width: 1, color: Colors.grey[300]),
                // 오른쪽: 서비스 기록 (70%)
                Expanded(
                  child: _selectedCustomer == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '고객을 선택해주세요',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ServiceTimeline(
                          customer: _selectedCustomer!,
                          records: _serviceRecords,
                          onAddRecord: _showAddRecordDialog,
                          onEditRecord: _showEditRecordDialog,
                          onDeleteRecord: _showDeleteRecordDialog,
                        ),
                ),
              ],
            ),
    );
  }
}
