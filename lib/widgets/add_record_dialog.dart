import 'package:flutter/material.dart';
import '../models/service_record.dart';

class AddRecordDialog extends StatefulWidget {
  final int customerId;
  final ServiceRecord? record;

  const AddRecordDialog({
    super.key,
    required this.customerId,
    this.record,
  });

  @override
  State<AddRecordDialog> createState() => _AddRecordDialogState();
}

class _AddRecordDialogState extends State<AddRecordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serviceContentController = TextEditingController();
  final _productNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  DateTime _serviceDate = DateTime.now();
  PaymentType _paymentType = PaymentType.cash;

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _serviceContentController.text = widget.record!.serviceContent;
      _productNameController.text = widget.record!.productName ?? '';
      _amountController.text = widget.record!.amount.toString();
      _memoController.text = widget.record!.memo ?? '';
      _serviceDate = widget.record!.serviceDate;
      _paymentType = widget.record!.paymentType;
    }
  }

  @override
  void dispose() {
    _serviceContentController.dispose();
    _productNameController.dispose();
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 제목과 버튼을 같은 행에 배치
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.record == null ? '서비스 기록 추가' : '서비스 기록 수정',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: '취소',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: _save,
                        icon: const Icon(Icons.check),
                        tooltip: '저장',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 날짜와 시술 내용을 한 줄에 배치
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 선택 (좌측)
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        if (!mounted) return;
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _serviceDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_serviceDate),
                          );
                          if (time != null) {
                            setState(() {
                              _serviceDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '${_serviceDate.year}.${_serviceDate.month.toString().padLeft(2, '0')}.${_serviceDate.day.toString().padLeft(2, '0')} ${_serviceDate.hour.toString().padLeft(2, '0')}:${_serviceDate.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 시술 내용 (우측)
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _serviceContentController,
                      decoration: const InputDecoration(
                        labelText: '시술 내용 *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '시술 내용을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 약품명과 금액을 한 줄에 배치
              Row(
                children: [
                  // 약품명 (좌측)
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: '약품명',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 금액 (우측)
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: '금액 *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      style: const TextStyle(fontSize: 14),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '금액을 입력해주세요';
                        }
                        if (int.tryParse(value) == null) {
                          return '숫자를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // 결제 타입
              Row(
                children: PaymentType.values.map((type) {
                  final isSelected = _paymentType == type;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _paymentType = type;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.blue
                              : Colors.grey[200],
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(0, 40),
                        ),
                        child: Text(
                          type.label,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              // 메모
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: 1,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final record = ServiceRecord(
        id: widget.record?.id,
        customerId: widget.customerId,
        serviceDate: _serviceDate,
        serviceContent: _serviceContentController.text.trim(),
        productName: _productNameController.text.trim().isEmpty
            ? null
            : _productNameController.text.trim(),
        paymentType: _paymentType,
        amount: int.parse(_amountController.text.trim()),
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        createdAt: widget.record?.createdAt ?? DateTime.now(),
      );
      Navigator.of(context).pop(record);
    }
  }
}
