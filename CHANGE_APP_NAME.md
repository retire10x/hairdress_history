# 앱 이름 변경 가이드

## ⚠️ 중요: 한 곳만 수정하면 되는 부분과 수동 수정이 필요한 부분

### ✅ 한 곳만 수정하면 자동으로 바뀌는 부분 (Dart 코드)

**`lib/constants/app_config.dart`** 파일만 수정하면 다음이 자동으로 변경됩니다:
- ✅ 앱 타이틀 (MaterialApp의 title)
- ✅ AppBar 제목 (화면 상단 표시)
- ✅ 모든 Dart 코드에서 사용하는 앱 이름

### ⚠️ 수동으로 함께 수정해야 하는 부분

Windows 실행 파일 이름과 제목을 변경하려면 다음 파일들도 함께 수정해야 합니다:

#### 1. `lib/constants/app_config.dart` 수정
```dart
class AppConfig {
  static const String appName = '반하다헤어';  // ← 여기 변경
  static const String appTitle = '고객 관리';
  static const String executableName = '반하다헤어';  // ← 여기도 변경
  // ...
}
```

#### 2. `windows/CMakeLists.txt` 수정 (7번째 줄)
```cmake
set(BINARY_NAME "반하다헤어")  // ← 여기 변경
```

#### 3. `windows/runner/Runner.rc` 수정 (92-98번째 줄)
```rc
VALUE "CompanyName", "반하다헤어" "\0"  // ← 여기들 변경
VALUE "FileDescription", "반하다헤어" "\0"
VALUE "InternalName", "반하다헤어" "\0"
VALUE "OriginalFilename", "반하다헤어.exe" "\0"
VALUE "ProductName", "반하다헤어" "\0"
```

#### 4. `windows/runner/main.cpp` 수정 (30번째 줄)
```cpp
if (!window.Create(L"반하다헤어", origin, size)) {  // ← 여기 변경
```

#### 5. `web/index.html` 수정 (26, 32번째 줄)
```html
<meta name="apple-mobile-web-app-title" content="고객 관리">  <!-- ← 여기 변경 -->
<title>고객 관리</title>  <!-- ← 여기 변경 -->
```

#### 6. `web/manifest.json` 수정 (2-3, 8번째 줄)
```json
{
    "name": "고객 관리",  // ← 여기 변경
    "short_name": "고객 관리",  // ← 여기 변경
    "description": "반하다헤어 고객 관리 시스템",  // ← 여기 변경
}
```

## 📝 요약

- **Dart 코드 내부**: `lib/constants/app_config.dart`만 수정하면 됨 ✅
- **Windows 실행 파일**: 위의 4개 파일 수정 필요 ⚠️
- **Web**: 위의 2개 파일 수정 필요 ⚠️

## 💡 팁

앱 이름을 자주 변경하지 않을 예정이라면, 현재처럼 `lib/constants/app_config.dart`만 수정해도 Dart 코드 내부에서는 모두 반영됩니다. Windows 실행 파일 이름은 빌드할 때만 필요하므로 필요할 때만 수정하면 됩니다.
