import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/customer.dart';
import '../models/service_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _initialized = false;

  DatabaseHelper._init();

  static Future<void> _initializeDatabaseFactory() async {
    if (!_initialized) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Desktop 플랫폼에서는 sqflite_common_ffi를 사용
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
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
    if (Platform.isWindows) {
      // Windows에서는 사용자 문서 폴더 사용
      final userProfile = Platform.environment['USERPROFILE'] ?? '';
      final documentsPath = path.join(userProfile, 'Documents', 'HairdressHistory');
      // 디렉토리가 없으면 생성
      final dir = Directory(documentsPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      dbPath = path.join(documentsPath, filePath);
    } else if (Platform.isLinux || Platform.isMacOS) {
      // Linux/MacOS에서는 홈 디렉토리 사용
      final homeDir = Platform.environment['HOME'] ?? '';
      final appDataPath = path.join(homeDir, '.hairdress_history');
      final dir = Directory(appDataPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      dbPath = path.join(appDataPath, filePath);
    } else {
      // Mobile 플랫폼에서는 sqflite의 기본 경로 사용
      // 하지만 sqflite_common_ffi를 사용하므로 직접 경로 지정
      final currentDir = Directory.current.path;
      dbPath = path.join(currentDir, filePath);
    }

    final db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _createDB,
    );
    
    // FOREIGN KEY 활성화 (SQLite는 기본적으로 비활성화)
    await db.execute('PRAGMA foreign_keys = ON');
    
    return db;
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

  Future<List<Customer>> getAllCustomers() async {
    final db = await database;
    final result = await db.query(
      'customers',
      orderBy: 'name ASC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
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

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
