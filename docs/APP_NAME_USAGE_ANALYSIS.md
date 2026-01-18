# "반하다헤어" 사용 위치 분석

이 문서는 코드베이스에서 "반하다헤어"가 사용되는 모든 위치를 카테고리별로 정리합니다.

## 📋 목차

1. [중앙 설정 파일](#1-중앙-설정-파일)
2. [Dart 코드](#2-dart-코드)
3. [Windows 빌드 파일](#3-windows-빌드-파일)
4. [설치 프로그램 스크립트](#4-설치-프로그램-스크립트)
5. [빌드 스크립트](#5-빌드-스크립트)
6. [문서 파일](#6-문서-파일)
7. [Web 설정](#7-web-설정)

---

## 1. 중앙 설정 파일

### `lib/constants/app_config.dart` ⭐ **핵심 설정 파일**

이 파일이 **가장 중요**합니다. 여기서 변경하면 Dart 코드에서 사용되는 모든 앱 이름이 자동으로 업데이트됩니다.

```dart
class AppConfig {
  static const String appName = '반하다헤어';              // 앱 브랜드 이름
  static const String appDescription = '반하다헤어 고객 관리 시스템';  // 앱 설명
  static const String companyName = '반하다헤어';          // 회사명
  static const String executableName = '반하다헤어';      // 실행 파일 이름
}
```

**사용 위치:**
- `lib/main.dart` - MaterialApp의 title
- `lib/screens/main_screen.dart` - AppBar 제목

---

## 2. Dart 코드

### `lib/main.dart`
- `MaterialApp`의 `title` 속성에 `AppConfig.appTitle` 사용 (현재 "고객 관리")
- 앱 이름은 `AppConfig.appName`을 통해 간접적으로 사용

### `lib/screens/main_screen.dart`
- `AppBar`의 `title`에 `AppConfig.appName` 사용
- 화면 상단에 "반하다헤어" 표시

---

## 3. Windows 빌드 파일

### 3.1 `windows/CMakeLists.txt`
- **CMake 프로젝트 이름**: `bandaha_hair` (영문, CMake 제약사항)
- **주석**: 실행 파일 이름이 "반하다헤어.exe"로 생성된다는 설명

### 3.2 `windows/runner/CMakeLists.txt`
- **OUTPUT_NAME**: `"반하다헤어"` (실제 실행 파일 이름)
- CMake 타겟은 `bandaha_hair`이지만, 출력 파일명은 `반하다헤어.exe`

### 3.3 `windows/runner/main.cpp`
- **창 제목**: `L"\uBC18\uD558\uB2E4\uD5E4\uC5B4"` (유니코드 이스케이프)
- 실제 값: "반하다헤어"
- **주의**: 인코딩 문제를 피하기 위해 유니코드 이스케이프 사용

### 3.4 `windows/runner/Runner.rc`
Windows 실행 파일의 속성 정보 (제어판 > 속성에서 확인 가능):

```c
VALUE "CompanyName", "반하다헤어" "\0"
VALUE "FileDescription", "반하다헤어" "\0"
VALUE "InternalName", "반하다헤어" "\0"
VALUE "LegalCopyright", "Copyright (C) 2026 반하다헤어. All rights reserved." "\0"
VALUE "OriginalFilename", "반하다헤어.exe" "\0"
VALUE "ProductName", "반하다헤어" "\0"
```

---

## 4. 설치 프로그램 스크립트

### 4.1 NSIS 스크립트 (`installer.nsi`)

**설치 프로그램 정보:**
- `Name "반하다헤어"` - 설치 프로그램 이름
- `OutFile "반하다헤어_Setup.exe"` - 생성될 설치 파일 이름
- `InstallDir "$PROGRAMFILES\반하다헤어"` - 기본 설치 경로

**시작 메뉴:**
- `CreateDirectory "$SMPROGRAMS\반하다헤어"`
- `CreateShortCut "$SMPROGRAMS\반하다헤어\반하다헤어.lnk"`

**바탕화면:**
- `CreateShortCut "$DESKTOP\반하다헤어.lnk"`

**레지스트리 (제어판 > 프로그램 제거):**
- `WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "DisplayName" "반하다헤어"`
- `WriteRegStr ... "Publisher" "반하다헤어"`

### 4.2 Inno Setup 스크립트 (`installer.iss`)

**설치 프로그램 정보:**
- `AppName=반하다헤어`
- `AppPublisher=반하다헤어`
- `DefaultDirName={pf}\반하다헤어`
- `DefaultGroupName=반하다헤어`
- `OutputBaseFilename=반하다헤어_Setup`

**바로가기:**
- `Name: "{group}\반하다헤어"; Filename: "{app}\반하다헤어.exe"`
- `Name: "{autodesktop}\반하다헤어"; Filename: "{app}\반하다헤어.exe"`

---

## 5. 빌드 스크립트

### 5.1 `build_release.bat`
- 배치 파일 제목: "반하다헤어 Windows Release 빌드"
- 출력 메시지: "반하다헤어.exe (빌드 후 생성됨)"
- 설명: 실행 파일 이름이 한글(반하다헤어.exe)로 생성됨

### 5.2 `build_installer.bat`
- 배치 파일 제목: "반하다헤어 설치 프로그램 생성"
- 파일 존재 확인: `build\windows\x64\runner\Release\반하다헤어.exe`
- 출력 메시지: "반하다헤어_Setup.exe"

---

## 6. 문서 파일

### 6.1 가이드 문서들
다음 문서들에서 "반하다헤어"가 예제로 사용됩니다:

- `INSTALLER_GUIDE.md` - 설치 프로그램 생성 가이드
- `DEPLOYMENT_GUIDE.md` - 배포 가이드
- `CHANGE_APP_NAME.md` - 앱 이름 변경 가이드
- `APP_CONFIG_README.md` - 앱 설정 가이드
- `CMAKE_FIX_README.md` - CMake 수정 가이드

**참고**: 이 문서들은 예제이므로 실제 앱 이름과 다를 수 있습니다.

---

## 7. Web 설정

### 7.1 `web/manifest.json`
```json
{
  "description": "반하다헤어 고객 관리 시스템"
}
```

---

## 📊 사용 위치 요약

| 카테고리 | 파일 수 | 중요도 | 변경 필요 여부 |
|---------|---------|--------|--------------|
| **중앙 설정** | 1 | ⭐⭐⭐ | ✅ 한 곳만 변경 |
| **Dart 코드** | 2 | ⭐⭐ | ✅ 자동 업데이트 |
| **Windows 빌드** | 4 | ⭐⭐⭐ | ⚠️ 수동 변경 필요 |
| **설치 스크립트** | 2 | ⭐⭐ | ⚠️ 수동 변경 필요 |
| **빌드 스크립트** | 2 | ⭐ | ⚠️ 수동 변경 필요 |
| **문서** | 5+ | - | 선택사항 |
| **Web 설정** | 1 | ⭐ | ⚠️ 수동 변경 필요 |

---

## 🔄 앱 이름 변경 시 작업 순서

### 1단계: 중앙 설정 변경 (필수)
```dart
// lib/constants/app_config.dart
class AppConfig {
  static const String appName = '새로운 이름';
  static const String companyName = '새로운 이름';
  static const String executableName = '새로운 이름';
}
```

### 2단계: Windows 빌드 파일 변경 (필수)
- `windows/runner/CMakeLists.txt` - `OUTPUT_NAME` 변경
- `windows/runner/main.cpp` - 창 제목 변경 (유니코드 이스케이프 사용)
- `windows/runner/Runner.rc` - 모든 `VALUE` 항목 변경

### 3단계: 설치 프로그램 스크립트 변경 (선택)
- `installer.nsi` - 모든 "반하다헤어" 문자열 변경
- `installer.iss` - 모든 "반하다헤어" 문자열 변경

### 4단계: 빌드 스크립트 변경 (선택)
- `build_release.bat` - 메시지 텍스트 변경
- `build_installer.bat` - 메시지 텍스트 변경

### 5단계: Web 설정 변경 (선택)
- `web/manifest.json` - description 변경

---

## ⚠️ 주의사항

1. **CMake 타겟 이름**: `bandaha_hair`는 영문으로 유지해야 합니다 (CMake 제약사항)
2. **유니코드 이스케이프**: `main.cpp`에서는 한글을 직접 사용하지 않고 유니코드 이스케이프 사용
3. **파일 인코딩**: Windows 빌드 파일들은 UTF-8 BOM 또는 적절한 인코딩으로 저장해야 함
4. **문서 파일**: 가이드 문서들은 예제이므로 실제 앱 이름과 다를 수 있음

---

## 📝 권장 사항

1. **중앙 집중식 관리**: `AppConfig` 클래스를 통해 Dart 코드에서 사용되는 앱 이름을 관리
2. **일관성 유지**: 모든 파일에서 동일한 앱 이름 사용
3. **문서화**: 앱 이름 변경 시 관련 문서도 함께 업데이트
4. **테스트**: 앱 이름 변경 후 빌드 및 실행 테스트 필수

---

## 🔍 빠른 검색

코드베이스에서 "반하다헤어"를 검색하려면:

```bash
# Windows PowerShell
Select-String -Pattern "반하다헤어" -Path . -Recurse

# 또는 grep 사용
grep -r "반하다헤어" .
```

---

**마지막 업데이트**: 2026년 1월
**총 사용 위치**: 약 136개 (문서 포함)
