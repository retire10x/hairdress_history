import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';
import '../models/service_record.dart';
import '../widgets/customer_list.dart';
import '../widgets/service_timeline.dart';
import '../widgets/add_customer_dialog.dart';
import '../widgets/add_record_dialog.dart';
import '../widgets/backup_restore_dialog.dart';

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

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final customers = await _db.getAllCustomers();
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('고객이 추가되었습니다')),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('고객 정보가 수정되었습니다')),
          );
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('고객 삭제'),
        content: Text('${customer.name} 고객을 삭제하시겠습니까?\n연결된 서비스 기록도 함께 삭제됩니다.'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('고객이 삭제되었습니다')),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('먼저 고객을 선택해주세요')),
      );
      return;
    }

    final result = await showDialog<ServiceRecord>(
      context: context,
      builder: (context) => AddRecordDialog(
        customerId: _selectedCustomer!.id!,
      ),
    );

    if (result != null) {
      try {
        await _db.insertServiceRecord(result);
        await _selectCustomer(_selectedCustomer!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서비스 기록이 추가되었습니다')),
          );
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
      builder: (context) => AddRecordDialog(
        customerId: record.customerId,
        record: record,
      ),
    );

    if (result != null) {
      try {
        await _db.updateServiceRecord(result);
        await _selectCustomer(_selectedCustomer!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서비스 기록이 수정되었습니다')),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('서비스 기록이 삭제되었습니다')),
          );
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

  Future<void> _showBackupRestoreDialog() async {
    await showDialog(
      context: context,
      builder: (context) => BackupRestoreDialog(
        onBackupComplete: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('백업이 완료되었습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        onRestoreComplete: () async {
          if (!mounted) return;
          
          // 데이터 복원 후 강제로 새로고침
          setState(() {
            _selectedCustomer = null;
            _serviceRecords = [];
            _isLoading = true;
          });
          
          // 데이터 다시 로드
          try {
            final customers = await _db.getAllCustomers();
            
            if (mounted) {
              setState(() {
                _customers = customers;
                _isLoading = false;
              });
              
              // 첫 번째 고객이 있으면 자동 선택
              if (customers.isNotEmpty) {
                await _selectCustomer(customers.first);
              }
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('데이터가 복원되었습니다 (고객 ${customers.length}명)'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('데이터 로드 중 오류: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('미용실 고객 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            tooltip: '백업/복원',
            onPressed: _showBackupRestoreDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Row(
              children: [
                // 왼쪽: 고객 목록 (30%)
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: CustomerList(
                    customers: _customers,
                    selectedCustomer: _selectedCustomer,
                    onCustomerSelected: _selectCustomer,
                    onAddCustomer: _showAddCustomerDialog,
                    onEditCustomer: _showEditCustomerDialog,
                    onDeleteCustomer: _showDeleteCustomerDialog,
                  ),
                ),
                // 구분선
                Container(
                  width: 1,
                  color: Colors.grey[300],
                ),
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
