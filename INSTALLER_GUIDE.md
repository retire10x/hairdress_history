# 설치 파일 배포 가이드

이 문서는 "반하다헤어" 앱을 Windows 설치 프로그램(.exe)으로 배포하는 전체 과정을 단계별로 안내합니다.

## 📋 목차

1. [사전 준비](#1-사전-준비)
2. [Release 빌드 생성](#2-release-빌드-생성)
3. [설치 프로그램 도구 선택](#3-설치-프로그램-도구-선택)
4. [NSIS를 사용한 설치 프로그램 생성](#4-nsis를-사용한-설치-프로그램-생성)
5. [Inno Setup을 사용한 설치 프로그램 생성](#5-inno-setup을-사용한-설치-프로그램-생성)
6. [설치 프로그램 테스트](#6-설치-프로그램-테스트)
7. [배포 및 배포 전 체크리스트](#7-배포-및-배포-전-체크리스트)
8. [문제 해결](#8-문제-해결)

---

## 1. 사전 준비

### 1.1 필수 확인 사항

배포 전에 다음 항목들을 확인하세요:

- [ ] **앱 이름 확인**: `lib/constants/app_config.dart`의 `AppConfig.appName`이 "반하다헤어"인지 확인
- [ ] **실행 파일 이름 확인**: `windows/CMakeLists.txt`의 `BINARY_NAME`이 "반하다헤어"인지 확인
- [ ] **버전 번호 확인**: `pubspec.yaml`의 `version` 필드 확인 (예: `1.0.0+1`)
- [ ] **데이터베이스 경로 확인**: 앱이 정상적으로 데이터를 저장하는지 테스트

### 1.2 필요한 도구

설치 프로그램을 만들기 위해 다음 중 하나를 설치해야 합니다:

- **NSIS (Nullsoft Scriptable Install System)**: 무료, 오픈소스
  - 다운로드: https://nsis.sourceforge.io/Download
  - 추천: Unicode 버전 (한글 지원)

- **Inno Setup**: 무료, 사용하기 쉬움 (추천)
  - 다운로드: https://jrsoftware.org/isdl.php
  - 추천: Inno Setup 6 이상

---

## 2. Release 빌드 생성

### 2.1 빌드 실행

프로젝트 루트 디렉토리에서 다음 명령어를 실행합니다:

```bash
flutter build windows --release
```

또는 제공된 배치 파일을 사용합니다:

```bash
build_release.bat
```

### 2.2 빌드 결과 확인

빌드가 성공하면 다음 위치에 파일들이 생성됩니다:

```
build/windows/x64/runner/Release/
├── 반하다헤어.exe          # 메인 실행 파일
├── flutter_windows.dll     # Flutter 런타임 라이브러리
├── data/                   # 앱 데이터 및 리소스
│   └── flutter_assets/    # Flutter 에셋 (이미지, 폰트 등)
├── vcruntime140.dll        # Visual C++ 런타임
└── (기타 DLL 파일들)       # 필요한 시스템 라이브러리들
```

### 2.3 빌드 결과 테스트

**중요**: 설치 프로그램을 만들기 전에 반드시 빌드된 실행 파일이 정상 작동하는지 테스트하세요.

1. `build/windows/x64/runner/Release/반하다헤어.exe` 더블클릭하여 실행
2. 앱이 정상적으로 시작되는지 확인
3. 주요 기능들이 작동하는지 테스트 (고객 추가, 서비스 기록 추가 등)
4. 데이터베이스가 정상적으로 생성되는지 확인

---

## 3. 설치 프로그램 도구 선택

### NSIS vs Inno Setup 비교

| 항목 | NSIS | Inno Setup |
|------|------|------------|
| **가격** | 무료 | 무료 |
| **한글 지원** | Unicode 버전 필요 | 기본 지원 |
| **사용 난이도** | 중간 | 쉬움 |
| **스크립트 작성** | .nsi 파일 | .iss 파일 |
| **추천 대상** | 고급 사용자 | 일반 사용자 |

**추천**: 처음 사용하는 경우 **Inno Setup**을 추천합니다. GUI가 제공되어 더 쉽게 사용할 수 있습니다.

---

## 4. NSIS를 사용한 설치 프로그램 생성

### 4.1 NSIS 설치

1. https://nsis.sourceforge.io/Download 에서 NSIS 다운로드
2. **중요**: **Unicode 버전**을 다운로드하세요 (한글 지원)
3. 설치 완료

### 4.2 NSIS 스크립트 작성

프로젝트 루트 디렉토리에 `installer.nsi` 파일을 생성하고 다음 내용을 작성합니다:

```nsis
; 반하다헤어 설치 프로그램 스크립트 (NSIS)
; 파일 인코딩: UTF-8 BOM

; ============================================
; 설치 프로그램 기본 정보
; ============================================
Name "반하다헤어"
OutFile "반하다헤어_Setup.exe"
InstallDir "$PROGRAMFILES\반하다헤어"
RequestExecutionLevel admin
Unicode true  ; 한글 지원

; ============================================
; 설치 페이지 설정
; ============================================
Page directory
Page instfiles

; ============================================
; 제거 페이지 설정
; ============================================
UninstPage uninstConfirm
UninstPage instfiles

; ============================================
; 설치 섹션
; ============================================
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
    ; 빌드된 모든 파일 복사
    File /r "build\windows\x64\runner\Release\*.*"
    
    ; 시작 메뉴 바로가기 생성
    CreateDirectory "$SMPROGRAMS\반하다헤어"
    CreateShortCut "$SMPROGRAMS\반하다헤어\반하다헤어.lnk" "$INSTDIR\반하다헤어.exe"
    CreateShortCut "$SMPROGRAMS\반하다헤어\제거.lnk" "$INSTDIR\Uninstall.exe"
    
    ; 바탕화면 바로가기 생성 (선택사항)
    CreateShortCut "$DESKTOP\반하다헤어.lnk" "$INSTDIR\반하다헤어.exe"
    
    ; 레지스트리 등록 (제어판 > 프로그램 제거에 표시)
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "DisplayName" "반하다헤어"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "Publisher" "반하다헤어"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "InstallLocation" "$INSTDIR"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "NoRepair" 1
    
    ; 제거 프로그램 생성
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; ============================================
; 제거 섹션
; ============================================
Section "Uninstall"
    ; 파일 삭제
    RMDir /r "$INSTDIR"
    
    ; 시작 메뉴 바로가기 삭제
    Delete "$SMPROGRAMS\반하다헤어\반하다헤어.lnk"
    Delete "$SMPROGRAMS\반하다헤어\제거.lnk"
    RMDir "$SMPROGRAMS\반하다헤어"
    
    ; 바탕화면 바로가기 삭제
    Delete "$DESKTOP\반하다헤어.lnk"
    
    ; 레지스트리 삭제
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어"
SectionEnd
```

### 4.3 NSIS 스크립트 컴파일

명령 프롬프트(CMD) 또는 PowerShell에서 다음 명령어를 실행합니다:

```bash
"C:\Program Files (x86)\NSIS\makensis.exe" installer.nsi
```

또는 NSIS 설치 경로가 다르다면:

```bash
makensis installer.nsi
```

### 4.4 설치 프로그램 생성 확인

컴파일이 성공하면 프로젝트 루트 디렉토리에 `반하다헤어_Setup.exe` 파일이 생성됩니다.

---

## 5. Inno Setup을 사용한 설치 프로그램 생성

### 5.1 Inno Setup 설치

1. https://jrsoftware.org/isdl.php 에서 Inno Setup 다운로드
2. 설치 완료 (Inno Setup Compiler 포함)

### 5.2 Inno Setup 스크립트 작성

프로젝트 루트 디렉토리에 `installer.iss` 파일을 생성하고 다음 내용을 작성합니다:

```iss
; 반하다헤어 설치 프로그램 스크립트 (Inno Setup)
; 파일 인코딩: UTF-8

[Setup]
; 앱 정보
AppName=반하다헤어
AppVersion=1.0.0
AppPublisher=반하다헤어
DefaultDirName={pf}\반하다헤어
DefaultGroupName=반하다헤어
OutputBaseFilename=반하다헤어_Setup
OutputDir=.

; 압축 설정
Compression=lzma2
SolidCompression=yes
LZMAUseSeparateProcess=yes

; 설치 설정
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
DisableProgramGroupPage=no
DisableReadyPage=no
DisableWelcomePage=no

; 아이콘 설정 (선택사항)
; SetupIconFile=windows\runner\resources\app_icon.ico
; UninstallDisplayIcon={app}\반하다헤어.exe

[Languages]
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; 빌드된 모든 파일 복사
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
; 시작 메뉴 바로가기
Name: "{group}\반하다헤어"; Filename: "{app}\반하다헤어.exe"
Name: "{group}\{cm:UninstallProgram,반하다헤어}"; Filename: "{uninstallexe}"

; 바탕화면 바로가기 (선택사항)
Name: "{autodesktop}\반하다헤어"; Filename: "{app}\반하다헤어.exe"; Tasks: desktopicon

[Run]
; 설치 완료 후 실행 (선택사항)
Filename: "{app}\반하다헤어.exe"; Description: "{cm:LaunchProgram,반하다헤어}"; Flags: nowait postinstall skipifsilent
```

### 5.3 Inno Setup 스크립트 컴파일

#### 방법 1: GUI 사용 (추천)

1. **Inno Setup Compiler** 실행
2. **File > Open** 메뉴에서 `installer.iss` 파일 열기
3. **Build > Compile** 메뉴 클릭 (또는 F9 키)
4. 컴파일 완료 후 `OutputDir`에 지정된 위치에 설치 프로그램 생성

#### 방법 2: 명령줄 사용

명령 프롬프트(CMD) 또는 PowerShell에서:

```bash
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
```

### 5.4 설치 프로그램 생성 확인

컴파일이 성공하면 프로젝트 루트 디렉토리(또는 `OutputDir`에 지정된 위치)에 `반하다헤어_Setup.exe` 파일이 생성됩니다.

---

## 6. 설치 프로그램 테스트

### 6.1 설치 테스트

1. **다른 폴더에서 테스트**: 현재 개발 환경과 다른 위치에서 설치 프로그램 실행
2. **설치 과정 확인**:
   - 설치 경로 선택이 정상 작동하는지
   - 파일 복사가 완료되는지
   - 바로가기가 생성되는지
3. **설치 후 실행 테스트**:
   - 시작 메뉴에서 앱 실행
   - 바탕화면 바로가기에서 앱 실행
   - 앱이 정상적으로 작동하는지 확인

### 6.2 제거 테스트

1. **제어판 > 프로그램 제거**에서 "반하다헤어" 찾기
2. **제거 실행**:
   - 제거 프로그램이 정상 작동하는지
   - 모든 파일이 삭제되는지
   - 바로가기가 삭제되는지
   - 레지스트리 항목이 삭제되는지

### 6.3 다른 컴퓨터에서 테스트 (선택사항)

가능하다면 다른 Windows 컴퓨터에서도 테스트하는 것을 권장합니다:

- Windows 10/11 다른 버전
- Visual C++ Redistributable이 설치되지 않은 환경
- 관리자 권한이 없는 사용자 계정

---

## 7. 배포 및 배포 전 체크리스트

### 7.1 배포 전 최종 체크리스트

- [ ] **빌드 확인**: Release 빌드가 정상적으로 생성되었는지
- [ ] **실행 테스트**: 빌드된 실행 파일이 정상 작동하는지
- [ ] **설치 프로그램 생성**: 설치 프로그램(.exe)이 생성되었는지
- [ ] **설치 테스트**: 설치 프로그램이 정상 작동하는지
- [ ] **제거 테스트**: 제거 프로그램이 정상 작동하는지
- [ ] **바로가기 확인**: 시작 메뉴, 바탕화면 바로가기가 생성되는지
- [ ] **데이터 저장 확인**: 앱이 정상적으로 데이터를 저장하는지
- [ ] **버전 정보 확인**: 설치 프로그램에 올바른 버전 정보가 표시되는지

### 7.2 배포 방법

생성된 설치 프로그램(`반하다헤어_Setup.exe`)을 다음 방법으로 배포할 수 있습니다:

1. **직접 전달**: USB 드라이브, 이메일 첨부 등
2. **클라우드 저장소**: Google Drive, OneDrive, Dropbox 등
3. **웹사이트**: 회사 웹사이트에 다운로드 링크 제공
4. **네트워크 공유**: 내부 네트워크 공유 폴더에 배치

### 7.3 사용자 안내

사용자에게 다음 사항을 안내하세요:

1. **시스템 요구사항**:
   - Windows 10 이상
   - 관리자 권한 (설치 시)

2. **설치 방법**:
   - `반하다헤어_Setup.exe` 더블클릭
   - 설치 마법사 따라하기
   - 설치 완료 후 시작 메뉴 또는 바탕화면에서 실행

3. **데이터 저장 위치**:
   - 데이터베이스: `C:\Users\[사용자명]\Documents\HairdressHistory\hairdress_history.db`
   - 백업 파일: `C:\Users\[사용자명]\Documents\HairdressHistory\backups\`

---

## 8. 문제 해결

### 8.1 "flutter_windows.dll을 찾을 수 없습니다" 오류

**원인**: 설치 프로그램에 모든 파일이 포함되지 않았습니다.

**해결**:
- NSIS/Inno Setup 스크립트에서 `File /r` 또는 `recursesubdirs` 옵션 확인
- `build/windows/x64/runner/Release/` 폴더 전체가 복사되는지 확인

### 8.2 한글이 깨지는 문제

**원인**: 스크립트 파일 인코딩 문제 또는 NSIS 비-Unicode 버전 사용

**해결**:
- 스크립트 파일을 **UTF-8 BOM** 형식으로 저장
- NSIS의 경우 **Unicode 버전** 사용
- Inno Setup의 경우 스크립트 상단에 `#pragma codepage(65001)` 추가 (필요시)

### 8.3 설치 프로그램이 생성되지 않음

**원인**: 스크립트 경로 오류 또는 빌드 미완료

**해결**:
- 스크립트 파일이 프로젝트 루트에 있는지 확인
- `build/windows/x64/runner/Release/` 폴더가 존재하는지 확인
- 빌드가 완료되었는지 확인 (`flutter build windows --release`)

### 8.4 설치 후 앱이 실행되지 않음

**원인**: Visual C++ Redistributable 미설치 또는 DLL 누락

**해결**:
- Visual C++ Redistributable 설치: https://aka.ms/vs/17/release/vc_redist.x64.exe
- 설치 프로그램에 Visual C++ Redistributable 포함 (고급)

### 8.5 제거 프로그램이 작동하지 않음

**원인**: 레지스트리 등록 오류 또는 파일 권한 문제

**해결**:
- 관리자 권한으로 설치했는지 확인
- 레지스트리 항목이 올바르게 등록되었는지 확인
- 수동 제거: 설치 폴더와 레지스트리 항목을 직접 삭제

---

## 9. 추가 팁

### 9.1 버전 정보 자동 업데이트

`pubspec.yaml`의 `version` 필드를 업데이트하면, 이를 NSIS/Inno Setup 스크립트에 자동으로 반영하는 스크립트를 만들 수 있습니다.

### 9.2 코드 서명 (선택사항)

전문적인 배포를 위해서는 코드 서명 인증서를 사용하여 설치 프로그램에 서명할 수 있습니다. 이는 Windows Defender 경고를 줄일 수 있습니다.

### 9.3 자동 업데이트 기능

향후 자동 업데이트 기능을 추가하려면 별도의 업데이트 서버와 클라이언트 로직이 필요합니다.

---

## 10. 빠른 참조

### 빌드 명령어
```bash
flutter build windows --release
```

### NSIS 컴파일
```bash
makensis installer.nsi
```

### Inno Setup 컴파일 (명령줄)
```bash
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer.iss
```

### 빌드 결과 위치
```
build/windows/x64/runner/Release/
```

---

## 문의 및 지원

문제가 발생하거나 추가 도움이 필요한 경우:
- Flutter 공식 문서: https://docs.flutter.dev/deployment/windows
- NSIS 문서: https://nsis.sourceforge.io/Docs/
- Inno Setup 문서: https://jrsoftware.org/ishelp/
