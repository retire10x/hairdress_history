import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

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
        // Windows: 실행 파일과 같은 경로
        final executablePath = Platform.resolvedExecutable;
        final executableDir = path.dirname(executablePath);
        filePath = path.join(executableDir, _fileName);
      } else if (Platform.isLinux || Platform.isMacOS) {
        // Linux/MacOS: 실행 파일과 같은 경로
        final executablePath = Platform.resolvedExecutable;
        final executableDir = path.dirname(executablePath);
        filePath = path.join(executableDir, _fileName);
      } else {
        // Mobile: 앱 데이터 디렉토리
        final currentDir = Directory.current.path;
        filePath = path.join(currentDir, _fileName);
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
