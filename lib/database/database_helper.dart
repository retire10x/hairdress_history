import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/customer.dart';
import '../models/service_record.dart';

// 플랫폼별 import - 웹이 아닐 때만 import
import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' if (dart.library.html) 'dart:html';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._init();

  static Future<void> _initializeDatabaseFactory() async {
    if (!_initialized) {
      if (kIsWeb) {
        // 웹 플랫폼에서는 기본 factory 사용 (sqflite 웹 구현)
        // 웹에서는 sqflite가 IndexedDB를 사용
        _initialized = true;
        return;
      }
      
      // Desktop 플랫폼(Windows, Linux, macOS)에서만 sqflite_common_ffi를 사용
      // Android/iOS는 네이티브 SQLite를 사용하므로 sqflite_common_ffi 불필요
      if (!kIsWeb) {
        // ignore: undefined_prefixed_name
        if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
          // ignore: undefined_prefixed_name
          sqfliteFfiInit();
          // ignore: undefined_prefixed_name
          databaseFactory = databaseFactoryFfi;
        }
        // Android/iOS는 기본 sqflite 사용 (네이티브 SQLite)
      }
      _initialized = true;
    }
  }

  Future<Database> get database async {
    await _initializeDatabaseFactory();
    if (_database != null) return _database!;
    _database = await _initDB('hairdress_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String dbPath;
    
    if (kIsWeb) {
      // 웹 플랫폼에서는 파일명만 사용 (IndexedDB에 저장됨)
      dbPath = filePath;
    } else {
      // 웹이 아닌 경우에만 Platform 사용 (kIsWeb 체크로 보호됨)
      // ignore: undefined_prefixed_name
      if (Platform.isWindows) {
        // Windows에서는 사용자 문서 폴더의 hairdress_history 폴더 사용
        // ignore: undefined_prefixed_name
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        final documentsPath = path.join(userProfile, 'Documents', 'hairdress_history');
        // 디렉토리가 없으면 생성
        // ignore: undefined_prefixed_name
        final dir = Directory(documentsPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        dbPath = path.join(documentsPath, filePath);
        // ignore: undefined_prefixed_name
      } else if (Platform.isLinux || Platform.isMacOS) {
        // Linux/MacOS에서는 홈 디렉토리의 hairdress_history 폴더 사용
        // ignore: undefined_prefixed_name
        final homeDir = Platform.environment['HOME'] ?? '';
        final appDataPath = path.join(homeDir, 'hairdress_history');
        // ignore: undefined_prefixed_name
        final dir = Directory(appDataPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        dbPath = path.join(appDataPath, filePath);
      } else {
        // Android/iOS Mobile 플랫폼에서는 sqflite의 getDatabasesPath()를 사용
        // Android에서는 앱의 데이터베이스 디렉토리를 사용해야 함
        try {
          // Android/iOS에서는 sqflite의 getDatabasesPath()를 사용
          if (!kIsWeb) {
            // ignore: undefined_prefixed_name
            if (Platform.isAndroid || Platform.isIOS) {
              // sqflite 패키지의 getDatabasesPath() 사용
              final databasesPath = await sqflite.getDatabasesPath();
              dbPath = path.join(databasesPath, filePath);
            } else {
              // 기타 모바일 플랫폼 (폴백)
              final appDir = await getApplicationDocumentsDirectory();
              final dir = Directory(appDir.path);
              if (!await dir.exists()) {
                await dir.create(recursive: true);
              }
              dbPath = path.join(appDir.path, filePath);
            }
          } else {
            // 웹은 이미 처리됨
            dbPath = filePath;
          }
        } catch (e) {
          debugPrint('경로 가져오기 실패: $e');
          // 폴백: 상대 경로 사용 (sqflite가 자동으로 처리)
          dbPath = filePath;
        }
      }
    }

    try {
      debugPrint('DB 경로: $dbPath');
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _createDB,
      );
      
      // FOREIGN KEY 활성화 (SQLite는 기본적으로 비활성화)
      // 웹에서는 PRAGMA가 작동하지 않을 수 있으므로 try-catch로 처리
      try {
        await db.execute('PRAGMA foreign_keys = ON');
      } catch (e) {
        debugPrint('PRAGMA foreign_keys 설정 실패 (웹 환경일 수 있음): $e');
      }
      
      // 테이블 존재 여부 확인 및 자동 생성
      await _ensureTablesExist(db);
      
      return db;
    } catch (e, stackTrace) {
      debugPrint('DB 열기 실패: $e');
      debugPrint('DB 경로: $dbPath');
      debugPrint('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// 테이블이 존재하는지 확인하고 없으면 생성
  Future<void> _ensureTablesExist(Database db) async {
    // customers 테이블 확인
    final customersTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='customers'",
    );
    
    if (customersTable.isEmpty) {
      // customers 테이블 생성
      await db.execute('''
        CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          memo TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }

    // service_records 테이블 확인
    final serviceRecordsTable = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='service_records'",
    );
    
    if (serviceRecordsTable.isEmpty) {
      // service_records 테이블 생성
      await db.execute('''
        CREATE TABLE service_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          customer_id INTEGER NOT NULL,
          service_date TEXT NOT NULL,
          service_content TEXT NOT NULL,
          product_name TEXT,
          payment_type TEXT NOT NULL,
          amount INTEGER NOT NULL,
          memo TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
        )
      ''');
      
      // 인덱스 생성
      await db.execute('''
        CREATE INDEX idx_customer_id ON service_records(customer_id)
      ''');
      await db.execute('''
        CREATE INDEX idx_service_date ON service_records(service_date)
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 고객 테이블
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        memo TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 서비스 기록 테이블
    await db.execute('''
      CREATE TABLE service_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        service_date TEXT NOT NULL,
        service_content TEXT NOT NULL,
        product_name TEXT,
        payment_type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        memo TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // 인덱스 생성
    await db.execute('''
      CREATE INDEX idx_customer_id ON service_records(customer_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_service_date ON service_records(service_date)
    ''');
  }

  // 고객 관련 메서드
  Future<int> insertCustomer(Customer customer) async {
    final db = await database;
    final map = customer.toMap();
    // INSERT 시에는 id를 제외해야 함
    map.remove('id');
    return await db.insert('customers', map);
  }

  Future<List<Customer>> getAllCustomers({
    String sortBy = 'name',
    String order = 'ASC',
  }) async {
    final db = await database;
    
    String query;
    if (sortBy == 'name') {
      query = 'SELECT * FROM customers ORDER BY name $order';
    } else if (sortBy == 'service_date') {
      // 서비스일순: 
      // - 내림차순(DESC): 최종 서비스일 기준 (최근 방문 고객 우선)
      // - 오름차순(ASC): 최초 서비스일 기준 (오래된 고객 우선)
      // 서비스 기록이 없는 고객은 맨 앞으로 배치 (정리 대상)
      if (order == 'ASC') {
        // 오름차순: 최초일 기준 (처음 방문한 날짜가 오래된 고객 우선)
        // 서비스 기록이 없는 고객은 맨 앞 (NULL 우선 처리)
        query = '''
          SELECT c.* 
          FROM customers c
          LEFT JOIN (
            SELECT customer_id, 
                   MIN(service_date) as first_service_date,
                   MAX(service_date) as last_service_date
            FROM service_records
            GROUP BY customer_id
          ) sr ON c.id = sr.customer_id
          ORDER BY 
            CASE WHEN sr.first_service_date IS NULL THEN 0 ELSE 1 END,
            COALESCE(sr.first_service_date, '0000-01-01') ASC,
            c.name ASC
        ''';
      } else {
        // 내림차순: 최종일 기준 (최근 방문 고객 우선)
        // 서비스 기록이 없는 고객은 맨 앞 (NULL 우선 처리)
        query = '''
          SELECT c.* 
          FROM customers c
          LEFT JOIN (
            SELECT customer_id, 
                   MIN(service_date) as first_service_date,
                   MAX(service_date) as last_service_date
            FROM service_records
            GROUP BY customer_id
          ) sr ON c.id = sr.customer_id
          ORDER BY 
            CASE WHEN sr.last_service_date IS NULL THEN 0 ELSE 1 END,
            COALESCE(sr.last_service_date, '0000-01-01') DESC,
            c.name ASC
        ''';
      }
    } else if (sortBy == 'amount') {
      // 금액순: 총 금액 기준
      query = '''
        SELECT c.* 
        FROM customers c
        LEFT JOIN (
          SELECT customer_id, COALESCE(SUM(amount), 0) as total_amount
          FROM service_records
          GROUP BY customer_id
        ) sr ON c.id = sr.customer_id
        ORDER BY sr.total_amount $order, c.name ASC
      ''';
    } else {
      query = 'SELECT * FROM customers ORDER BY name ASC';
    }
    
    try {
      final result = await db.rawQuery(query);
      return result.map((map) {
        try {
          return Customer.fromMap(map);
        } catch (e) {
          debugPrint('고객 데이터 파싱 오류: $e');
          debugPrint('데이터: $map');
          rethrow;
        }
      }).toList();
    } catch (e, stackTrace) {
      debugPrint('고객 목록 조회 오류: $e');
      debugPrint('쿼리: $query');
      debugPrint('스택 트레이스: $stackTrace');
      rethrow;
    }
  }

  /// 고객별 총 서비스 금액 계산
  Future<int> getTotalAmountByCustomer(int customerId) async {
    final db = await database;
    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(amount), 0) as total
      FROM service_records
      WHERE customer_id = ?
      ''',
      [customerId],
    );
    return result.first['total'] as int;
  }

  Future<Customer?> getCustomer(int id) async {
    final db = await database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await database;
    return await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    
    // FOREIGN KEY 활성화 (CASCADE 삭제를 위해)
    await db.execute('PRAGMA foreign_keys = ON');
    
    // 연결된 서비스 기록 먼저 삭제 (CASCADE가 작동하지 않을 경우를 대비)
    await db.delete(
      'service_records',
      where: 'customer_id = ?',
      whereArgs: [id],
    );
    
    // 고객 삭제
    return await db.delete(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 서비스 기록 관련 메서드
  Future<int> insertServiceRecord(ServiceRecord record) async {
    final db = await database;
    final map = record.toMap();
    // INSERT 시에는 id를 제외해야 함
    map.remove('id');
    return await db.insert('service_records', map);
  }

  Future<List<ServiceRecord>> getServiceRecordsByCustomer(int customerId) async {
    final db = await database;
    final result = await db.query(
      'service_records',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'service_date DESC',
    );
    return result.map((map) => ServiceRecord.fromMap(map)).toList();
  }

  /// 특정 날짜에 서비스 기록이 있는 고객 ID 목록을 반환합니다
  Future<List<int>> getCustomerIdsByServiceDate(DateTime date) async {
    final db = await database;
    // 날짜만 비교 (시간 제외)
    // ISO8601 형식: YYYY-MM-DD
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    // SQLite의 DATE 함수 대신 문자열 비교 사용 (더 호환성 있음)
    // service_date는 ISO8601 형식으로 저장되어 있으므로 날짜 부분만 비교
    final result = await db.rawQuery(
      '''
      SELECT DISTINCT customer_id
      FROM service_records
      WHERE SUBSTR(service_date, 1, 10) = ?
      ''',
      [dateStr],
    );
    return result.map((row) => row['customer_id'] as int).toList();
  }

  Future<int> updateServiceRecord(ServiceRecord record) async {
    final db = await database;
    return await db.update(
      'service_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> deleteServiceRecord(int id) async {
    final db = await database;
    return await db.delete(
      'service_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 모든 서비스 기록 삭제
  Future<int> deleteAllServiceRecords() async {
    final db = await database;
    return await db.delete('service_records');
  }

  /// 모든 데이터 초기화 (고객 및 서비스 기록 모두 삭제)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('service_records');
    await db.delete('customers');
  }

  /// 테스트 데이터 생성 (30명의 고객, 각 1~5개의 서비스 기록)
  Future<void> generateTestData() async {
    final db = await database;
    
    // 기존 데이터 삭제
    await db.delete('service_records');
    await db.delete('customers');
    
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    final now = DateTime.now();
    final serviceContents = [
      '컷트', '펌', '염색', '매직', '트리트먼트',
      '컷트+펌', '컷트+염색', '매직+트리트먼트', '전체 시술',
      '컷트+펌+염색', '디자인 펌', '볼륨 매직', '스트레이트 펌'
    ];
    final productNames = [
      '샴푸', '트리트먼트', '에센스', '왁스', '스프레이',
      '헤어팩', '세럼', '오일', null, null
    ];
    final paymentTypes = PaymentType.values;
    
    // 30명의 고객 생성
    final customerNames = [
      '김철수', '이영희', '박민수', '최지영', '정수진',
      '강동원', '한소희', '류준열', '전지현', '송혜교',
      '이병헌', '손예진', '공유', '김태희', '원빈',
      '김하늘', '장동건', '고소영', '차승원', '이정재',
      '황정민', '송강호', '최민식', '이병헌', '조인성',
      '현빈', '이민호', '박보검', '강동원', '유아인'
    ];
    
    for (int i = 0; i < 30; i++) {
      // 고객 생성
      final customer = Customer(
        name: customerNames[i],
        phone: '010-${(1000 + i * 37).toString().substring(0, 4)}-${(5000 + i * 23).toString().substring(0, 4)}',
        memo: i % 3 == 0 ? '메모 ${i + 1}' : null,
        createdAt: now.subtract(Duration(days: 365 - i * 10)),
      );
      final customerId = await insertCustomer(customer);
      
      // 각 고객당 1~5개의 서비스 기록 생성
      final recordCount = random.nextInt(5) + 1; // 1~5개
      
      for (int j = 0; j < recordCount; j++) {
        final daysAgo = random.nextInt(365); // 최근 1년 내 랜덤
        final serviceDate = now.subtract(Duration(days: daysAgo));
        final hour = random.nextInt(14) + 9; // 9시~22시
        final minute = random.nextInt(60);
        final serviceDateTime = DateTime(
          serviceDate.year,
          serviceDate.month,
          serviceDate.day,
          hour,
          minute,
        );
        
        final contentIndex = random.nextInt(serviceContents.length);
        final productIndex = random.nextInt(productNames.length);
        final paymentIndex = random.nextInt(paymentTypes.length);
        
        final record = ServiceRecord(
          customerId: customerId,
          serviceDate: serviceDateTime,
          serviceContent: serviceContents[contentIndex],
          productName: productNames[productIndex],
          paymentType: paymentTypes[paymentIndex],
          amount: (random.nextInt(50) + 10) * 10000, // 10만원~60만원
          memo: j % 2 == 0 ? '메모 ${j + 1}' : null,
          createdAt: serviceDateTime,
        );
        
        await insertServiceRecord(record);
      }
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
