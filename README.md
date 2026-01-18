# 미용실 고객 관리 앱 (Hairdress History)

Flutter로 개발된 미용실 고객 및 서비스 기록 관리 애플리케이션입니다.

## 📋 목차

- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [빠른 시작](#빠른-시작)
- [데이터베이스](#데이터베이스)
- [빌드 및 배포](#빌드-및-배포)
- [문서](#문서)
- [주요 특징](#주요-특징)

---

## 주요 기능

- ✅ **고객 관리**: 고객 정보 추가, 수정, 삭제
- ✅ **서비스 기록 관리**: 시술 내역, 약품명, 결제 정보 기록 및 수정, 삭제
- ✅ **Master-Detail UI**: 왼쪽 30% 고객 목록, 오른쪽 70% 상세 기록
- ✅ **타임라인 표시**: 날짜별 서비스 기록을 타임라인 형태로 표시
- ✅ **정렬 기능**: 이름, 서비스일, 총액 기준 정렬 (오름차순/내림차순)
- ✅ **백업/복원**: CSV 파일로 데이터 백업 및 복원 (MSSQL 마이그레이션 지원)
- ✅ **데이터 초기화**: 비밀번호로 보호된 전체 데이터 삭제 기능
- ✅ **외부 제목 설정**: AppBar 제목을 외부 txt 파일에서 읽기

---

## 기술 스택

- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **SQLite**: 로컬 데이터베이스 (sqflite, sqflite_common_ffi)
- **CSV**: 백업/복원 파일 형식
- **Windows**: 주요 배포 플랫폼

---

## 빠른 시작

### 개발 환경 설정

```bash
# 의존성 설치
flutter pub get

# Windows에서 실행
flutter run -d windows

# Release 빌드
flutter build windows --release
```

### 빌드 스크립트 사용

```bash
# Release 빌드 (빌드 후 폴더 자동 열기)
build_release.bat

# 설치 프로그램 생성
build_installer.bat
```

---

## 데이터베이스

### 데이터베이스 위치

**Windows:**
```
C:\Users\[사용자명]\Documents\HairdressHistory\hairdress_history.db
```

**백업 파일 위치:**
```
C:\Users\[사용자명]\Documents\HairdressHistory\backups\hairdress_backup_*.csv
```

### 데이터베이스 구조

#### customers 테이블
- `id`: 고유 ID (자동 증가)
- `name`: 고객명 (필수)
- `phone`: 전화번호 (선택)
- `memo`: 메모 (선택)
- `created_at`: 생성일시

#### service_records 테이블
- `id`: 고유 ID (자동 증가)
- `customer_id`: 고객 ID (외래키, CASCADE 삭제)
- `service_date`: 서비스 날짜/시간 (필수)
- `service_content`: 시술 내용 (필수)
- `product_name`: 약품명 (선택)
- `payment_type`: 결제 타입 (cash/card/transfer)
- `amount`: 금액 (필수)
- `memo`: 메모 (선택)
- `created_at`: 생성일시

---

## 빌드 및 배포

### Release 빌드

```bash
flutter build windows --release
```

빌드 결과물 위치: `build/windows/x64/runner/Release/`

### 배포 방법

1. **포터블 버전**: Release 폴더 전체를 ZIP으로 압축
2. **설치 프로그램**: NSIS 또는 Inno Setup 사용

자세한 내용은 [docs/INSTALLER_GUIDE.md](docs/INSTALLER_GUIDE.md)를 참고하세요.

---

## 문서

상세한 문서는 `docs/` 폴더에 정리되어 있습니다:

### 📖 개발 가이드
- [APP_CONFIG_README.md](docs/APP_CONFIG_README.md) - 앱 설정 변경 가이드
- [APP_NAME_USAGE_ANALYSIS.md](docs/APP_NAME_USAGE_ANALYSIS.md) - 앱 이름 사용 위치 분석
- [APP_TITLE_FILE_GUIDE.md](docs/APP_TITLE_FILE_GUIDE.md) - AppBar 제목 외부 파일 설정
- [CHANGE_APP_NAME.md](docs/CHANGE_APP_NAME.md) - 앱 이름 변경 가이드
- [CMAKE_FIX_README.md](docs/CMAKE_FIX_README.md) - CMake 한글 이름 문제 해결

### 🚀 배포 가이드
- [DEPLOYMENT_GUIDE.md](docs/DEPLOYMENT_GUIDE.md) - Windows 배포 가이드
- [INSTALLER_GUIDE.md](docs/INSTALLER_GUIDE.md) - 설치 파일 배포 가이드
- [RELEASE_FILES_EXPLANATION.md](docs/RELEASE_FILES_EXPLANATION.md) - Release 폴더 파일 설명

### 📊 데이터 마이그레이션
- [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md) - MSSQL → Flutter SQLite 마이그레이션 가이드

### 📚 전체 문서 목록
- [docs/README.md](docs/README.md) - 문서 목록 및 빠른 참조

---

## 주요 특징

### 1. 전체 화면 실행
앱 실행 시 자동으로 전체 화면(최대화)으로 표시됩니다.

### 2. 외부 제목 설정
AppBar 제목을 외부 txt 파일(`app_title.txt`)에서 읽어옵니다:
- 실행 파일과 같은 폴더에 `app_title.txt` 파일 생성
- 파일 내용이 AppBar 제목으로 표시됨
- 파일이 없으면 기본값(`hairdress_history`) 사용

자세한 내용: [docs/APP_TITLE_FILE_GUIDE.md](docs/APP_TITLE_FILE_GUIDE.md)

### 3. MSSQL 마이그레이션 지원
기존 MSSQL Server 데이터를 CSV 파일로 추출하여 Flutter 앱으로 마이그레이션할 수 있습니다.

자세한 내용: [docs/MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md)

### 4. 정렬 기능
- **이름**: 고객명 기준 정렬
- **서비스일**: 최초/최종 서비스일 기준 정렬 (서비스 기록 없는 고객은 맨 앞)
- **총액**: 고객별 총 서비스 금액 기준 정렬

### 5. 데이터 보호
- 데이터 초기화 시 비밀번호 확인 필요
- 백업/복원 기능으로 데이터 보호

---

## 시스템 요구사항

- **Windows**: Windows 10 이상
- **Flutter**: 3.10.7 이상
- **SQLite**: 자동 포함 (별도 설치 불필요)

---

## 프로젝트 구조

```
hairdress_history/
├── lib/
│   ├── constants/          # 앱 설정 상수
│   ├── database/           # 데이터베이스 헬퍼
│   ├── models/             # 데이터 모델
│   ├── screens/            # 화면
│   ├── services/           # 서비스 (백업, 제목 등)
│   └── widgets/            # 재사용 가능한 위젯
├── windows/                # Windows 빌드 설정
├── docs/                   # 문서
├── assets/                 # 에셋 (아이콘 등)
└── build_release.bat       # Release 빌드 스크립트
```

---

## 라이선스

이 프로젝트는 개인 사용 목적으로 개발되었습니다.

---

## 버전 정보

- **현재 버전**: 1.0.0+1
- **최종 업데이트**: 2026-01-18
