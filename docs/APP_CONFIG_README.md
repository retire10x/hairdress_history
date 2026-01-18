# 앱 설정 변경 가이드

앱의 브랜드 이름, 타이틀, 실행 파일 이름 등을 변경하려면 **`lib/constants/app_config.dart`** 파일만 수정하면 됩니다.

## 변경 방법

1. `lib/constants/app_config.dart` 파일을 엽니다.
2. `AppConfig` 클래스의 상수 값을 원하는 값으로 변경합니다.
3. Windows 실행 파일 이름도 변경하려면 다음 파일들도 함께 수정해야 합니다:
   - `windows/CMakeLists.txt` - `BINARY_NAME` 값
   - `windows/runner/Runner.rc` - `ProductName`, `FileDescription` 등
   - `windows/runner/main.cpp` - 창 제목

## 현재 설정

- **앱 브랜드 이름**: `AppConfig.appName` = "반하다헤어"
- **앱 타이틀**: `AppConfig.appTitle` = "고객 관리"
- **실행 파일 이름**: `AppConfig.executableName` = "반하다헤어"

## 주의사항

- Windows 빌드 파일들은 C++/CMake 파일이므로 Dart 상수를 직접 사용할 수 없습니다.
- 앱 이름을 변경할 때는 `lib/constants/app_config.dart`와 Windows 빌드 파일들을 모두 동기화해야 합니다.
- 빌드 후에는 실행 파일 이름이 변경된 것을 확인할 수 있습니다.
