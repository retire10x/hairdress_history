import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

/// AppBar 제목을 외부 txt 파일에서 읽어오는 서비스
class AppTitleService {
  static const String _fileName = 'app_title.txt';
  static String? _cachedTitle;
  
  /// 실행 파일과 같은 경로에서 app_title.txt 파일을 읽어옵니다.
  /// 파일이 없거나 읽을 수 없으면 기본값을 반환합니다.
  static Future<String> getAppTitle({String defaultTitle = '반하다 헤어', bool forceReload = false}) async {
    // forceReload가 true이면 캐시 무시
    if (forceReload) {
      _cachedTitle = null;
    }
    
    // 캐시된 값이 있으면 반환
    if (_cachedTitle != null) {
      debugPrint('캐시된 app_title 사용: $_cachedTitle');
      return _cachedTitle!;
    }
    
    try {
      String filePath;
      
      if (Platform.isWindows) {
        // Windows: Documents/hairdress_history 폴더
        final userProfile = Platform.environment['USERPROFILE'] ?? '';
        filePath = path.join(userProfile, 'Documents', 'hairdress_history', _fileName);
      } else if (Platform.isLinux || Platform.isMacOS) {
        // Linux/MacOS: 홈 디렉토리의 hairdress_history 폴더
        final homeDir = Platform.environment['HOME'] ?? '';
        filePath = path.join(homeDir, 'hairdress_history', _fileName);
      } else {
        // Android/iOS: DB 파일 상위 디렉토리에서 app_title.txt 찾기
        // ignore: undefined_prefixed_name
        if (Platform.isAndroid) {
          // Android: DB 파일 경로를 가져와서 상위 디렉토리 사용
          // DB 경로: /data/data/com.example.hairdress_history/databases/hairdress_history.db
          // 상위 디렉토리: /data/data/com.example.hairdress_history/
          try {
            final databasesPath = await sqflite.getDatabasesPath();
            // databases 폴더의 상위 디렉토리 (앱 데이터 디렉토리)
            final appDataDir = path.dirname(databasesPath);
            filePath = path.join(appDataDir, _fileName);
            debugPrint('Android databases 경로: $databasesPath');
            debugPrint('Android app_data 디렉토리: $appDataDir');
            debugPrint('Android app_title.txt 경로: $filePath');
          } catch (e) {
            debugPrint('Failed to get Android directory for app_title.txt: $e');
            // 폴백: 앱의 문서 디렉토리 사용
            final appDir = await getApplicationDocumentsDirectory();
            filePath = path.join(appDir.path, _fileName);
            debugPrint('폴백 경로 사용: $filePath');
          }
        } else {
          // iOS: 앱의 문서 디렉토리 사용
          try {
            final appDir = await getApplicationDocumentsDirectory();
            filePath = path.join(appDir.path, 'hairdress_history', _fileName);
            debugPrint('iOS app_title.txt 경로: $filePath');
          } catch (e) {
            debugPrint('Failed to get app directory for app_title.txt: $e');
            _cachedTitle = defaultTitle;
            return defaultTitle;
          }
        }
      }
      
      final file = File(filePath);
      
      debugPrint('app_title.txt 파일 경로: $filePath');
      debugPrint('파일 존재 여부: ${await file.exists()}');
      
      // 파일이 존재하는지 확인
      if (await file.exists()) {
        // 파일 읽기 (UTF-8 인코딩)
        String content;
        try {
          // UTF-8로 읽기 시도
          final bytes = await file.readAsBytes();
          content = utf8.decode(bytes);
          debugPrint('파일 내용 (UTF-8): $content');
        } catch (e) {
          // UTF-8 실패 시 기본 인코딩으로 읽기
          debugPrint('UTF-8 읽기 실패, 기본 인코딩으로 시도: $e');
          content = await file.readAsString();
          debugPrint('파일 내용 (기본 인코딩): $content');
        }
        
        // 앞뒤 공백 제거
        content = content.trim();
        debugPrint('공백 제거 후 내용: "$content"');
        
        // 내용이 있으면 사용, 없으면 기본값
        if (content.isNotEmpty) {
          _cachedTitle = content;
          debugPrint('app_title 설정 완료: $content');
          return content;
        } else {
          debugPrint('파일 내용이 비어있음, 기본값 사용');
        }
      } else {
        debugPrint('app_title.txt 파일이 존재하지 않습니다: $filePath');
      }
    } catch (e) {
      // 파일 읽기 실패 시 기본값 반환
      debugPrint('Failed to read app_title.txt: $e');
    }
    
    // 기본값 반환 및 캐시
    _cachedTitle = defaultTitle;
    return defaultTitle;
  }
  
  /// 캐시를 초기화합니다 (파일을 수정한 후 다시 읽을 때 사용)
  static void clearCache() {
    _cachedTitle = null;
  }
}
