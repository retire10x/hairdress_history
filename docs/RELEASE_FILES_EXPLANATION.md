# Release 폴더 파일 설명

Flutter Windows 앱을 실행하려면 **Release 폴더의 모든 파일**이 필요합니다. exe 파일만으로는 실행할 수 없습니다.

## 📁 Release 폴더 구조

```
build/windows/x64/runner/Release/
├── hairdress_history.exe          # 메인 실행 파일 (필수)
├── flutter_windows.dll            # Flutter 런타임 라이브러리 (필수)
├── charset_converter_plugin.dll   # 플러그인 DLL (필수)
└── data/                          # 앱 데이터 및 리소스 (필수)
    ├── app.so                     # AOT 컴파일된 Dart 코드 (필수)
    ├── icudtl.dat                 # ICU 데이터 (국제화 지원, 필수)
    └── flutter_assets/            # Flutter 에셋 (필수)
        ├── AssetManifest.bin      # 에셋 매니페스트
        ├── FontManifest.json      # 폰트 매니페스트
        ├── fonts/                 # 폰트 파일들
        │   └── MaterialIcons-Regular.otf
        ├── packages/              # 패키지 에셋
        │   └── cupertino_icons/
        └── shaders/               # 셰이더 파일들
            ├── ink_sparkle.frag
            └── stretch_effect.frag
```

## 🔍 각 파일의 역할

### 1. 실행 파일 및 DLL

#### `hairdress_history.exe` ⭐ **필수**
- 메인 실행 파일
- 앱의 진입점
- **이 파일만으로는 실행 불가능**

#### `flutter_windows.dll` ⭐ **필수**
- Flutter 엔진 런타임 라이브러리
- Flutter 프레임워크의 핵심 기능 제공
- **없으면**: "flutter_windows.dll을 찾을 수 없습니다" 오류 발생

#### `charset_converter_plugin.dll` ⭐ **필수**
- charset_converter 플러그인의 네이티브 라이브러리
- CSV 파일 인코딩 변환에 사용
- **없으면**: 백업/복원 기능이 작동하지 않음

### 2. data/ 폴더

#### `data/app.so` ⭐ **필수**
- AOT (Ahead-Of-Time) 컴파일된 Dart 코드
- 앱의 모든 비즈니스 로직이 포함됨
- **없으면**: 앱이 시작되지 않음

#### `data/icudtl.dat` ⭐ **필수**
- ICU (International Components for Unicode) 데이터
- 날짜, 숫자, 문자열 포맷팅 등 국제화 지원
- **없으면**: 날짜/시간 포맷팅 오류 발생

#### `data/flutter_assets/` ⭐ **필수**
- 앱의 모든 에셋 (이미지, 폰트, 셰이더 등)
- **AssetManifest.bin**: 에셋 목록 및 경로 정보
- **FontManifest.json**: 사용되는 폰트 정보
- **fonts/**: 폰트 파일들 (Material Icons 등)
- **packages/**: 패키지에서 제공하는 에셋
- **shaders/**: GPU 셰이더 파일들
- **없으면**: UI가 제대로 렌더링되지 않음 (폰트, 아이콘 누락)

## ❌ exe 파일만으로는 안 되는 이유

1. **Flutter 런타임 의존성**
   - `flutter_windows.dll`이 없으면 Flutter 엔진을 로드할 수 없음
   - `app.so`가 없으면 Dart 코드를 실행할 수 없음

2. **리소스 의존성**
   - `flutter_assets/` 폴더가 없으면 UI 리소스를 로드할 수 없음
   - 폰트, 아이콘, 이미지 등이 모두 이 폴더에 있음

3. **플러그인 의존성**
   - 플러그인 DLL 파일들이 없으면 해당 기능이 작동하지 않음

4. **국제화 의존성**
   - `icudtl.dat`가 없으면 날짜/시간 포맷팅이 실패함

## ✅ 배포 시 주의사항

### 포터블 버전 배포
- **Release 폴더 전체**를 ZIP으로 압축하여 배포
- 폴더 구조를 그대로 유지해야 함
- 사용자는 압축 해제 후 `hairdress_history.exe`를 실행

### 설치 프로그램 배포
- NSIS/Inno Setup 스크립트에서 `File /r` 또는 `recursesubdirs` 옵션 사용
- **모든 파일과 폴더**를 포함해야 함
- 설치 후에도 폴더 구조가 유지되어야 함

## 🧪 테스트 방법

### 1. 파일 삭제 테스트
각 파일을 하나씩 삭제하고 실행해보면 오류 메시지를 확인할 수 있습니다:

```powershell
# flutter_windows.dll 삭제 후 실행
Remove-Item "build\windows\x64\runner\Release\flutter_windows.dll"
.\hairdress_history.exe
# 오류: "flutter_windows.dll을 찾을 수 없습니다"

# data/app.so 삭제 후 실행
Remove-Item "build\windows\x64\runner\Release\data\app.so"
.\hairdress_history.exe
# 오류: 앱이 시작되지 않음

# data/flutter_assets/ 삭제 후 실행
Remove-Item -Recurse "build\windows\x64\runner\Release\data\flutter_assets"
.\hairdress_history.exe
# 오류: UI가 제대로 렌더링되지 않음 (폰트, 아이콘 누락)
```

### 2. 다른 컴퓨터에서 테스트
- Release 폴더 전체를 다른 컴퓨터로 복사
- `hairdress_history.exe` 실행
- 정상 작동 확인

## 📊 파일 크기 분석

일반적인 Flutter Windows 앱의 파일 크기:

- `hairdress_history.exe`: 약 100-200 KB
- `flutter_windows.dll`: 약 20-30 MB
- `app.so`: 앱 크기에 따라 다름 (수 MB)
- `icudtl.dat`: 약 10-20 MB
- `flutter_assets/`: 에셋 크기에 따라 다름 (수백 KB ~ 수 MB)
- 플러그인 DLL: 각각 수백 KB ~ 수 MB

**총 크기**: 보통 50-100 MB 정도

## 💡 최적화 팁

1. **불필요한 에셋 제거**: 사용하지 않는 이미지, 폰트 제거
2. **AOT 컴파일**: Release 빌드 시 자동으로 AOT 컴파일됨
3. **트리 쉐이킹**: 사용하지 않는 코드 자동 제거

## 🔗 관련 문서

- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - 배포 가이드
- [INSTALLER_GUIDE.md](INSTALLER_GUIDE.md) - 설치 프로그램 생성 가이드

---

**결론**: Release 폴더의 **모든 파일과 폴더**가 필요합니다. exe 파일만으로는 실행할 수 없습니다.
