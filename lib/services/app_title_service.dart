import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// AppBar 제목을 외부 txt 파일에서 읽어오는 서비스
class AppTitleService {
  static const String _fileName = 'app_title.txt';
  static String? _cachedTitle;
  
  /// 실행 파일과 같은 경로에서 app_title.txt 파일을 읽어옵니다.
  /// 파일이 없거나 읽을 수 없으면 기본값을 반환합니다.
  static Future<String> getAppTitle({String defaultTitle = 'hairdress_history'}) async {
    // 캐시된 값이 있으면 반환
    if (_cachedTitle != null) {
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
        // Android/iOS: 파일 관리자로 접근 가능한 외부 저장소 경로 사용
        // ignore: undefined_prefixed_name
        if (Platform.isAndroid) {
          // Android: /storage/emulated/0/Android/data/com.example.hairdress_history/app_title.txt
          try {
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              // /storage/emulated/0/Android/data/com.example.hairdress_history/files/
              // -> /storage/emulated/0/Android/data/com.example.hairdress_history/app_title.txt
              final androidDataPath = path.dirname(path.dirname(externalDir.path));
              filePath = path.join(androidDataPath, 'com.example.hairdress_history', _fileName);
              debugPrint('Android app_title.txt 경로: $filePath');
            } else {
              // 외부 저장소를 사용할 수 없으면 앱의 문서 디렉토리 사용
              final appDir = await getApplicationDocumentsDirectory();
              filePath = path.join(appDir.path, 'hairdress_history', _fileName);
              debugPrint('외부 저장소 사용 불가, 앱 문서 디렉토리 사용: $filePath');
            }
          } catch (e) {
            debugPrint('Failed to get Android directory for app_title.txt: $e');
            final appDir = await getApplicationDocumentsDirectory();
            filePath = path.join(appDir.path, 'hairdress_history', _fileName);
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
      
      // 파일이 존재하는지 확인
      if (await file.exists()) {
        // 파일 읽기 (UTF-8 인코딩)
        String content;
        try {
          // UTF-8로 읽기 시도
          final bytes = await file.readAsBytes();
          content = utf8.decode(bytes);
        } catch (e) {
          // UTF-8 실패 시 기본 인코딩으로 읽기
          content = await file.readAsString();
        }
        
        // 앞뒤 공백 제거
        content = content.trim();
        
        // 내용이 있으면 사용, 없으면 기본값
        if (content.isNotEmpty) {
          _cachedTitle = content;
          return content;
        }
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
