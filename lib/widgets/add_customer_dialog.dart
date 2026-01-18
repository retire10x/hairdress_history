import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/customer.dart';

class AddCustomerDialog extends StatefulWidget {
  final Customer? customer;

  const AddCustomerDialog({super.key, this.customer});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _memoController = TextEditingController();
  
  // 전화번호 마스크: 010-####-#### (하이픈 포함 총 13자리)
  late final MaskTextInputFormatter _phoneMaskFormatter;

  @override
  void initState() {
    super.initState();
    
    // 전화번호 마스크 초기화 (010-####-####, 총 13자리)
    // 010-이 기본으로 들어가고, 그 다음 4자리-4자리 입력
    _phoneMaskFormatter = MaskTextInputFormatter(
      mask: '010-####-####',
      filter: {'#': RegExp(r'[0-9]')},
    );
    
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name;
      // 기존 전화번호가 있으면 마스크 적용
      if (widget.customer!.phone != null && widget.customer!.phone!.isNotEmpty) {
        // 기존 전화번호를 마스크 형식으로 변환
        final phoneDigits = widget.customer!.phone!.replaceAll(RegExp(r'[^0-9]'), '');
        if (phoneDigits.length >= 11) {
          _phoneController.text = '010-${phoneDigits.substring(3, 7)}-${phoneDigits.substring(7)}';
        } else {
          _phoneController.text = widget.customer!.phone!;
        }
      } else {
        // 새로 추가하는 경우 기본값 '010-' 설정
        _phoneController.text = '010-';
      }
      _memoController.text = widget.customer!.memo ?? '';
    } else {
      // 새로 추가하는 경우 기본값 '010-' 설정
      _phoneController.text = '010-';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.customer == null ? '고객 추가' : '고객 수정',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              // 이름
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '이름 *',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 전화번호
              TextFormField(
                controller: _phoneController,
                inputFormatters: [_phoneMaskFormatter],
                maxLength: 13, // 하이픈 포함 총 13자리 제한
                decoration: const InputDecoration(
                  labelText: '전화번호',
                  hintText: '010-1234-5678',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  counterText: '', // 문자 카운터 숨김
                ),
                style: const TextStyle(fontSize: 16),
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  // 입력이 비어있으면 기본값 '010-'으로 복원
                  if (value.isEmpty) {
                    _phoneController.text = '010-';
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: '010-'.length),
                    );
                  }
                  // 13자리가 넘으면 자동으로 잘라냄
                  if (value.length > 13) {
                    _phoneController.text = value.substring(0, 13);
                    _phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: 13),
                    );
                  }
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty && value != '010-') {
                    // 하이픈 포함 정확히 13자리인지 확인
                    if (value.length != 13) {
                      return '전화번호는 13자리여야 합니다 (010-1234-5678)';
                    }
                    // 형식 확인: 010-####-####
                    final phoneRegex = RegExp(r'^010-\d{4}-\d{4}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return '올바른 전화번호 형식이 아닙니다 (010-1234-5678)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // 메모
              TextFormField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: '메모',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              // 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      minimumSize: const Size(0, 50),
                    ),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      minimumSize: const Size(0, 50),
                    ),
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // 전화번호 처리 (하이픈 포함 정확히 13자리)
      String? phoneValue;
      final phoneText = _phoneController.text.trim();
      if (phoneText.isNotEmpty && phoneText != '010-') {
        // 13자리인지 확인
        if (phoneText.length == 13) {
          phoneValue = phoneText;
        } else {
          // 13자리가 아니면 숫자만 추출하여 재구성
          final digitsOnly = phoneText.replaceAll(RegExp(r'[^0-9]'), '');
          if (digitsOnly.length == 11) {
            phoneValue = '010-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
          } else {
            phoneValue = phoneText;
          }
        }
      }
      
      final customer = Customer(
        id: widget.customer?.id,
        name: _nameController.text.trim(),
        phone: phoneValue,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
      );
      Navigator.of(context).pop(customer);
    }
  }
}
