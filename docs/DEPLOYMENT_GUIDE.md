# Windows 배포 가이드

## 1. Release 빌드 생성

### 기본 빌드 명령어
```bash
flutter build windows --release
```

이 명령어를 실행하면 `build/windows/x64/runner/Release/` 폴더에 배포 가능한 파일들이 생성됩니다.

### 빌드 옵션
- `--release`: 최적화된 릴리스 빌드 (기본값)
- `--profile`: 프로파일링용 빌드
- `--debug`: 디버그 빌드 (배포용 아님)

## 2. 빌드 결과물 확인

빌드가 완료되면 다음 위치에 파일들이 생성됩니다:

```
build/windows/x64/runner/Release/
├── 반하다헤어.exe          # 메인 실행 파일
├── flutter_windows.dll     # Flutter 런타임
├── data/                   # 앱 데이터 및 리소스
│   └── flutter_assets/    # Flutter 에셋
└── (기타 DLL 파일들)       # 필요한 라이브러리들
```

## 3. 배포 방법

### 방법 1: 포터블 버전 (간단한 배포)

1. **전체 폴더 복사**
   - `build/windows/x64/runner/Release/` 폴더 전체를 복사
   - ZIP 파일로 압축하여 배포

2. **사용자에게 전달**
   - ZIP 파일을 압축 해제
   - `반하다헤어.exe` 실행

**장점**: 설치 불필요, 간단함  
**단점**: 여러 파일이 필요, 사용자가 혼란스러울 수 있음

### 방법 2: 설치 프로그램 생성 (권장)

#### A. NSIS 사용 (무료, 오픈소스)

1. **NSIS 설치**
   - https://nsis.sourceforge.io/Download 에서 다운로드
   - 설치 완료

2. **NSIS 스크립트 생성**
   - `installer.nsi` 파일 생성 (프로젝트 루트에)
   - 아래 스크립트 사용

3. **스크립트 실행**
   ```bash
   makensis installer.nsi
   ```

#### B. Inno Setup 사용 (무료, 추천)

1. **Inno Setup 설치**
   - https://jrsoftware.org/isdl.php 에서 다운로드
   - 설치 완료

2. **Inno Setup 스크립트 생성**
   - Inno Setup Compiler 실행
   - File > New로 새 스크립트 생성
   - 아래 설정 사용

3. **스크립트 컴파일**
   - Build > Compile

## 4. NSIS 설치 스크립트 예제

`installer.nsi` 파일을 프로젝트 루트에 생성:

```nsis
; 반하다헤어 설치 프로그램 스크립트

; 설치 프로그램 정보
Name "반하다헤어"
OutFile "반하다헤어_Setup.exe"
InstallDir "$PROGRAMFILES\반하다헤어"
RequestExecutionLevel admin

; 설치 페이지
Page directory
Page instfiles

; 제거 페이지
UninstPage uninstConfirm
UninstPage instfiles

; 설치 섹션
Section "MainSection" SEC01
    SetOutPath "$INSTDIR"
    
    ; 실행 파일 복사
    File /r "build\windows\x64\runner\Release\*.*"
    
    ; 시작 메뉴 바로가기 생성
    CreateDirectory "$SMPROGRAMS\반하다헤어"
    CreateShortCut "$SMPROGRAMS\반하다헤어\반하다헤어.lnk" "$INSTDIR\반하다헤어.exe"
    CreateShortCut "$SMPROGRAMS\반하다헤어\제거.lnk" "$INSTDIR\Uninstall.exe"
    
    ; 바탕화면 바로가기 생성 (선택사항)
    CreateShortCut "$DESKTOP\반하다헤어.lnk" "$INSTDIR\반하다헤어.exe"
    
    ; 레지스트리 등록
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "DisplayName" "반하다헤어"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "UninstallString" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어" "Publisher" "반하다헤어"
    
    ; 제거 프로그램 생성
    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

; 제거 섹션
Section "Uninstall"
    ; 파일 삭제
    RMDir /r "$INSTDIR"
    
    ; 바로가기 삭제
    Delete "$SMPROGRAMS\반하다헤어\반하다헤어.lnk"
    Delete "$SMPROGRAMS\반하다헤어\제거.lnk"
    RMDir "$SMPROGRAMS\반하다헤어"
    Delete "$DESKTOP\반하다헤어.lnk"
    
    ; 레지스트리 삭제
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\반하다헤어"
SectionEnd
```

## 5. Inno Setup 스크립트 예제

`installer.iss` 파일을 프로젝트 루트에 생성:

```iss
[Setup]
AppName=반하다헤어
AppVersion=1.0.0
DefaultDirName={pf}\반하다헤어
DefaultGroupName=반하다헤어
OutputBaseFilename=반하다헤어_Setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\반하다헤어"; Filename: "{app}\반하다헤어.exe"
Name: "{group}\제거"; Filename: "{uninstallexe}"
Name: "{commondesktop}\반하다헤어"; Filename: "{app}\반하다헤어.exe"

[Run]
Filename: "{app}\반하다헤어.exe"; Description: "반하다헤어 실행"; Flags: nowait postinstall skipifsilent
```

## 6. 배포 체크리스트

빌드 전 확인사항:
- [ ] `lib/constants/app_config.dart`에서 앱 이름 확인
- [ ] `windows/CMakeLists.txt`에서 실행 파일 이름 확인
- [ ] 버전 번호 확인 (`pubspec.yaml`의 `version`)

빌드 후 확인사항:
- [ ] `반하다헤어.exe` 파일이 생성되었는지 확인
- [ ] 실행 파일이 정상 작동하는지 테스트
- [ ] 필요한 DLL 파일들이 모두 포함되었는지 확인

배포 전 확인사항:
- [ ] 설치 프로그램이 정상 작동하는지 테스트
- [ ] 제거 프로그램이 정상 작동하는지 테스트
- [ ] 다른 컴퓨터에서 테스트 (필요한 경우)

## 7. 빠른 배포 명령어

### 빌드만 하기
```bash
flutter build windows --release
```

### 빌드 후 폴더 열기
```bash
flutter build windows --release && explorer build\windows\x64\runner\Release
```

## 8. 문제 해결

### "flutter_windows.dll을 찾을 수 없습니다" 오류
- `data` 폴더와 모든 DLL 파일이 실행 파일과 같은 폴더에 있는지 확인
- Release 폴더 전체를 복사해야 함

### 실행 파일이 작동하지 않음
- Visual C++ Redistributable이 설치되어 있는지 확인
- Windows 10 이상인지 확인

### 설치 프로그램 생성 오류
- NSIS/Inno Setup이 올바르게 설치되었는지 확인
- 스크립트 경로가 올바른지 확인
- 빌드가 완료되었는지 확인

## 9. 추가 리소스

- [Flutter Windows 배포 공식 문서](https://docs.flutter.dev/deployment/windows)
- [NSIS 문서](https://nsis.sourceforge.io/Docs/)
- [Inno Setup 문서](https://jrsoftware.org/ishelp/)
