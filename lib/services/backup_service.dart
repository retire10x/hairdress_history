import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:charset_converter/charset_converter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/customer.dart';
import '../models/service_record.dart';

class BackupService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// 백업 데이터 생성 (CSV 바이트 배열)
  /// 반환: UTF-8 BOM이 포함된 CSV 바이트 배열
  /// Android/iOS에서 사용자가 선택한 위치에 저장할 때 사용
  Future<List<int>> createBackupData() async {
    // 고객 데이터 가져오기
    final customers = await _db.getAllCustomers();
    
    // 서비스 기록 가져오기
    final allRecords = <ServiceRecord>[];
    for (final customer in customers) {
      if (customer.id != null) {
        final records = await _db.getServiceRecordsByCustomer(customer.id!);
        allRecords.addAll(records);
      }
    }

    // CSV 데이터 생성
    final csvData = <List<String>>[];
    
    // 헤더 행 (CUSTOMER)
    csvData.add(['TYPE', 'id', 'name', 'phone', 'memo', 'created_at']);
    
    // 고객 데이터
    for (final customer in customers) {
      csvData.add([
        'CUSTOMER',
        customer.id?.toString() ?? '',
        customer.name,
        customer.phone ?? '',
        customer.memo ?? '',
        customer.createdAt.toIso8601String(),
      ]);
    }
    
    // 헤더 행 (SERVICE_RECORD)
    csvData.add(['TYPE', 'id', 'customer_id', 'service_date', 'service_content', 
                 'product_name', 'payment_type', 'amount', 'memo', 'created_at']);
    
    // 서비스 기록 데이터
    for (final record in allRecords) {
      csvData.add([
        'SERVICE_RECORD',
        record.id?.toString() ?? '',
        record.customerId.toString(),
        record.serviceDate.toIso8601String(),
        record.serviceContent,
        record.productName ?? '',
        record.paymentType.name,
        record.amount.toString(),
        record.memo ?? '',
        record.createdAt.toIso8601String(),
      ]);
    }

    // CSV 문자열 생성
    final csvString = const ListToCsvConverter().convert(csvData);
    
    // UTF-8 BOM 추가
    final bom = utf8.encode('\uFEFF');
    final csvBytes = utf8.encode(csvString);
    final fileBytes = [...bom, ...csvBytes];
    
    return fileBytes;
  }

  /// 백업 파일 생성 (CSV 형식)
  /// 반환: 생성된 파일 경로
  Future<String> createBackup() async {
    try {
      // 백업 데이터 생성
      final fileBytes = await createBackupData();

      // 백업 파일 경로 생성
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'hairdress_backup_$timestamp.csv';
      
      String backupDir;
      if (kIsWeb) {
        // 웹에서는 다운로드 폴더 사용 불가, 임시 경로 사용
        backupDir = '';
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        backupDir = path.join(userProfile, 'Documents', 'hairdress_history', 'backups');
      } else if (Platform.isLinux || Platform.isMacOS) {
        final homeDir = Platform.environment['HOME'] ?? '';
        backupDir = path.join(homeDir, 'hairdress_history', 'backups');
      } else {
        // Android/iOS: 공개 디렉토리 우선 사용 (사용자가 파일 관리자에서 접근 가능)
        // 1순위: 다운로드 폴더 (사용자가 가장 쉽게 접근 가능)
        // 참고: 백업은 FilePicker를 사용하므로 이 경로는 자동 백업 시에만 사용됨
        try {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            backupDir = path.join(downloadsDir.path, 'hairdress_history', 'backups');
          } else {
            // 다운로드 폴더를 사용할 수 없으면 앱의 외부 저장소 디렉토리 사용
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              backupDir = path.join(externalDir.path, 'hairdress_history', 'backups');
            } else {
              // 외부 저장소를 사용할 수 없으면 앱의 문서 디렉토리 사용
              final appDir = await getApplicationDocumentsDirectory();
              backupDir = path.join(appDir.path, 'hairdress_history', 'backups');
            }
          }
        } catch (e) {
          // path_provider 실패 시 앱의 문서 디렉토리 사용
          try {
            final appDir = await getApplicationDocumentsDirectory();
            backupDir = path.join(appDir.path, 'hairdress_history', 'backups');
          } catch (e2) {
            // 모든 방법 실패 시 임시 디렉토리 사용
            try {
              final tempDir = await getTemporaryDirectory();
              backupDir = path.join(tempDir.path, 'hairdress_history', 'backups');
            } catch (e3) {
              backupDir = '';
            }
          }
        }
      }

      // 디렉토리 생성
      if (backupDir.isNotEmpty) {
        final dir = Directory(backupDir);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      }

      // 파일 저장
      String filePath;
      if (kIsWeb || backupDir.isEmpty) {
        // 웹이나 경로를 얻을 수 없는 경우 임시 파일로 저장
        final tempDir = await getTemporaryDirectory();
        filePath = path.join(tempDir.path, fileName);
      } else {
        filePath = path.join(backupDir, fileName);
      }
      
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      return filePath;
    } catch (e) {
      throw Exception('백업 생성 중 오류 발생: $e');
    }
  }

  /// CSV 파일에서 데이터 복원
  /// [filePath]: 복원할 CSV 파일 경로
  /// [overwrite]: true면 기존 데이터 삭제 후 복원, false면 병합
  Future<RestoreResult> restoreFromFile(String filePath, {bool overwrite = false}) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('파일을 찾을 수 없습니다: $filePath');
      }

      // CSV 파일 읽기 (여러 인코딩 시도)
      String csvString = '';
      try {
        // 먼저 바이트로 읽어서 인코딩 감지
        final bytes = await file.readAsBytes();
        
        // UTF-8 BOM 확인
        if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
          // UTF-8 BOM 제거 후 읽기
          csvString = utf8.decode(bytes.sublist(3));
        } else {
          // 여러 인코딩 시도
          bool decoded = false;
          
          // 1. UTF-8 시도
          try {
            csvString = utf8.decode(bytes, allowMalformed: false);
            decoded = true;
          } catch (e) {
            // UTF-8 실패
          }
          
          // 2. UTF-8 실패 시 CP949 (Windows-949) 시도 (Android에서는 charset_converter가 작동하지 않을 수 있음)
          if (!decoded) {
            try {
              // Android에서는 charset_converter가 작동하지 않을 수 있으므로 try-catch로 처리
              if (!kIsWeb) {
                // ignore: undefined_prefixed_name
                if (Platform.isAndroid || Platform.isIOS) {
                  // Android/iOS에서는 charset_converter를 사용하지 않고 UTF-8만 시도
                  // 인코딩 문제가 있으면 사용자가 UTF-8로 저장하도록 안내
                } else {
                  final converted = await CharsetConverter.decode('Windows-949', bytes);
                  csvString = converted;
                  decoded = true;
                }
              } else {
                final converted = await CharsetConverter.decode('Windows-949', bytes);
                csvString = converted;
                decoded = true;
              }
            } catch (e) {
              // CP949 실패
            }
          }
          
          // 3. CP949도 실패하면 EUC-KR 시도 (Android에서는 제외)
          if (!decoded) {
            try {
              // Android/iOS에서는 charset_converter를 사용하지 않음
              if (!kIsWeb) {
                // ignore: undefined_prefixed_name
                if (!Platform.isAndroid && !Platform.isIOS) {
                  final converted = await CharsetConverter.decode('EUC-KR', bytes);
                  csvString = converted;
                  decoded = true;
                }
              } else {
                final converted = await CharsetConverter.decode('EUC-KR', bytes);
                csvString = converted;
                decoded = true;
              }
            } catch (e) {
              // EUC-KR 실패
            }
          }
          
          // 4. 모두 실패하면 UTF-8 (allowMalformed)로 강제 시도
          if (!decoded) {
            csvString = utf8.decode(bytes, allowMalformed: true);
          }
        }
      } catch (e) {
        // 모든 인코딩 실패 시 기본 UTF-8 시도
        try {
          csvString = await file.readAsString(encoding: utf8);
        } catch (e2) {
          throw Exception('CSV 파일을 읽을 수 없습니다. 인코딩 문제일 수 있습니다: $e2');
        }
      }
      
      if (csvString.isEmpty) {
        throw Exception('CSV 파일이 비어있거나 읽을 수 없습니다');
      }
      
      final csvData = const CsvToListConverter().convert(csvString);

      if (csvData.isEmpty) {
        throw Exception('CSV 파일이 비어있습니다');
      }

      final customers = <Customer>[];
      final records = <ServiceRecord>[];
      
      List<String>? currentHeaders;

      for (int i = 0; i < csvData.length; i++) {
        final row = csvData[i];
        if (row.isEmpty) continue;

        final firstCell = row[0]?.toString().trim().toUpperCase();
        
        // TYPE 헤더 행 확인
        if (firstCell == 'TYPE') {
          currentHeaders = row.map((e) => e?.toString().trim()).toList().cast<String>();
          continue;
        }

        // 데이터 행 처리
        if (firstCell == 'CUSTOMER') {
          if (currentHeaders == null || currentHeaders.length < 6) {
            continue; // 헤더가 없으면 스킵
          }

          try {
            final customer = _parseCustomer(row, currentHeaders);
            if (customer != null) {
              customers.add(customer);
            }
          } catch (e) {
            // 파싱 오류는 무시하고 계속 진행
            continue;
          }
        } else if (firstCell == 'SERVICE_RECORD') {
          if (currentHeaders == null || currentHeaders.length < 10) {
            continue; // 헤더가 없으면 스킵
          }

          try {
            final record = _parseServiceRecord(row, currentHeaders);
            if (record != null) {
              records.add(record);
            }
          } catch (e) {
            // 파싱 오류는 무시하고 계속 진행
            continue;
          }
        }
      }

      // 데이터베이스에 저장
      int customerCount = 0;
      int recordCount = 0;

      if (overwrite) {
        // 기존 데이터 삭제 (외래키 제약조건으로 서비스 기록도 자동 삭제)
        final existingCustomers = await _db.getAllCustomers();
        for (final customer in existingCustomers) {
          if (customer.id != null) {
            await _db.deleteCustomer(customer.id!);
          }
        }
      }

      // 고객 데이터 삽입
      final customerIdMap = <int, int>{}; // 원본 ID -> 새 ID 매핑
      
      for (final customer in customers) {
        if (customer.id != null) {
          // ID 충돌 방지를 위해 ID 없이 삽입
          final newCustomer = Customer(
            name: customer.name,
            phone: customer.phone,
            memo: customer.memo,
            createdAt: customer.createdAt,
          );
          final newId = await _db.insertCustomer(newCustomer);
          customerIdMap[customer.id!] = newId;
          customerCount++;
        }
      }

      // 서비스 기록 데이터 삽입
      for (final record in records) {
        final newCustomerId = customerIdMap[record.customerId];
        if (newCustomerId != null) {
          final newRecord = ServiceRecord(
            customerId: newCustomerId,
            serviceDate: record.serviceDate,
            serviceContent: record.serviceContent,
            productName: record.productName,
            paymentType: record.paymentType,
            amount: record.amount,
            memo: record.memo,
            createdAt: record.createdAt,
          );
          await _db.insertServiceRecord(newRecord);
          recordCount++;
        }
      }

      return RestoreResult(
        customerCount: customerCount,
        recordCount: recordCount,
        success: true,
      );
    } catch (e) {
      return RestoreResult(
        customerCount: 0,
        recordCount: 0,
        success: false,
        error: e.toString(),
      );
    }
  }

  Customer? _parseCustomer(List<dynamic> row, List<String> headers) {
    try {
      final idIndex = headers.indexOf('id');
      final nameIndex = headers.indexOf('name');
      final phoneIndex = headers.indexOf('phone');
      final memoIndex = headers.indexOf('memo');
      final createdAtIndex = headers.indexOf('created_at');

      if (nameIndex == -1) return null;

      final name = row[nameIndex]?.toString().trim() ?? '';
      if (name.isEmpty) return null;

      final id = idIndex != -1 && row[idIndex] != null
          ? int.tryParse(row[idIndex].toString())
          : null;

      final phone = phoneIndex != -1 && row[phoneIndex] != null
          ? row[phoneIndex].toString().trim()
          : null;
      final phoneValue = phone != null && phone.isNotEmpty ? phone : null;

      final memo = memoIndex != -1 && row[memoIndex] != null
          ? row[memoIndex].toString().trim()
          : null;
      final memoValue = memo != null && memo.isNotEmpty ? memo : null;

      DateTime createdAt;
      if (createdAtIndex != -1 && row[createdAtIndex] != null) {
        try {
          createdAt = DateTime.parse(row[createdAtIndex].toString());
        } catch (e) {
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }

      return Customer(
        id: id,
        name: name,
        phone: phoneValue,
        memo: memoValue,
        createdAt: createdAt,
      );
    } catch (e) {
      return null;
    }
  }

  ServiceRecord? _parseServiceRecord(List<dynamic> row, List<String> headers) {
    try {
      final customerIdIndex = headers.indexOf('customer_id');
      final serviceDateIndex = headers.indexOf('service_date');
      final serviceContentIndex = headers.indexOf('service_content');
      final productNameIndex = headers.indexOf('product_name');
      final paymentTypeIndex = headers.indexOf('payment_type');
      final amountIndex = headers.indexOf('amount');
      final memoIndex = headers.indexOf('memo');
      final createdAtIndex = headers.indexOf('created_at');

      if (customerIdIndex == -1 ||
          serviceDateIndex == -1 ||
          serviceContentIndex == -1 ||
          paymentTypeIndex == -1 ||
          amountIndex == -1) {
        return null;
      }

      final customerId = int.tryParse(row[customerIdIndex].toString());
      if (customerId == null) return null;

      final serviceContent = row[serviceContentIndex]?.toString().trim() ?? '';
      if (serviceContent.isEmpty) return null;

      DateTime serviceDate;
      try {
        serviceDate = DateTime.parse(row[serviceDateIndex].toString());
      } catch (e) {
        return null;
      }

      final paymentTypeStr = row[paymentTypeIndex]?.toString().trim().toLowerCase() ?? 'cash';
      PaymentType paymentType;
      switch (paymentTypeStr) {
        case 'cash':
        case '현금':
          paymentType = PaymentType.cash;
          break;
        case 'card':
        case '카드':
          paymentType = PaymentType.card;
          break;
        case 'transfer':
        case '송금':
        case '계좌이체':
        case '이체':
          paymentType = PaymentType.transfer;
          break;
        default:
          paymentType = PaymentType.cash;
      }

      final amount = int.tryParse(row[amountIndex].toString()) ?? 0;

      final productName = productNameIndex != -1 && row[productNameIndex] != null
          ? row[productNameIndex].toString().trim()
          : null;
      final productNameValue = productName != null && productName.isNotEmpty ? productName : null;

      final memo = memoIndex != -1 && row[memoIndex] != null
          ? row[memoIndex].toString().trim()
          : null;
      final memoValue = memo != null && memo.isNotEmpty ? memo : null;

      DateTime createdAt;
      if (createdAtIndex != -1 && row[createdAtIndex] != null) {
        try {
          createdAt = DateTime.parse(row[createdAtIndex].toString());
        } catch (e) {
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }

      return ServiceRecord(
        customerId: customerId,
        serviceDate: serviceDate,
        serviceContent: serviceContent,
        productName: productNameValue,
        paymentType: paymentType,
        amount: amount,
        memo: memoValue,
        createdAt: createdAt,
      );
    } catch (e) {
      return null;
    }
  }
}

class RestoreResult {
  final int customerCount;
  final int recordCount;
  final bool success;
  final String? error;

  RestoreResult({
    required this.customerCount,
    required this.recordCount,
    required this.success,
    this.error,
  });
}
