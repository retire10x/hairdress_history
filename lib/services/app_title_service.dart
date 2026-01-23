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
        // Android/iOS: 공개 디렉토리 우선 사용 (사용자가 파일 관리자에서 접근 가능)
        // 1순위: 다운로드 폴더 (사용자가 가장 쉽게 접근 가능)
        try {
          final downloadsDir = await getDownloadsDirectory();
          if (downloadsDir != null) {
            filePath = path.join(downloadsDir.path, 'hairdress_history', _fileName);
            final file = File(filePath);
            if (await file.exists()) {
              // 파일이 있으면 읽기
              final bytes = await file.readAsBytes();
              final content = utf8.decode(bytes).trim();
              if (content.isNotEmpty) {
                _cachedTitle = content;
                return content;
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to access Downloads directory: $e');
        }
        
        // 2순위: 앱의 외부 저장소 디렉토리 (권한 없이 접근 가능, 하지만 파일 관리자에서 보이지 않음)
        try {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            filePath = path.join(externalDir.path, 'hairdress_history', _fileName);
            final file = File(filePath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final content = utf8.decode(bytes).trim();
              if (content.isNotEmpty) {
                _cachedTitle = content;
                return content;
              }
            }
          }
        } catch (e) {
          debugPrint('Failed to access external storage directory: $e');
        }
        
        // 3순위: 앱의 문서 디렉토리
        try {
          final appDir = await getApplicationDocumentsDirectory();
          filePath = path.join(appDir.path, 'hairdress_history', _fileName);
        } catch (e) {
          debugPrint('Failed to get app directory for app_title.txt: $e');
          _cachedTitle = defaultTitle;
          return defaultTitle;
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
