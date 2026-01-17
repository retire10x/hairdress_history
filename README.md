# 미용실 고객 관리 앱 (Hairdress History)

Flutter로 개발된 미용실 고객 및 서비스 기록 관리 애플리케이션입니다.

## 주요 기능

- ✅ **고객 관리**: 고객 정보 추가, 수정, 삭제
- ✅ **서비스 기록 관리**: 시술 내역, 약품명, 결제 정보 기록
- ✅ **Master-Detail UI**: 아이패드 가로 화면 최적화 (왼쪽 30% 고객 목록, 오른쪽 70% 상세 기록)
- ✅ **타임라인 표시**: 날짜별 서비스 기록을 타임라인 형태로 표시
- ✅ **백업/복원**: CSV 파일로 데이터 백업 및 복원 (MSSQL 마이그레이션 지원)
- ✅ **터치 친화적**: 모든 버튼과 리스트 항목 최소 50px 높이

## 기술 스택

- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **SQLite**: 로컬 데이터베이스 (sqflite, sqflite_common_ffi)
- **CSV**: 백업/복원 파일 형식

## 데이터베이스 구조

### customers 테이블
- id: 고유 ID
- name: 고객명
- phone: 전화번호
- memo: 메모
- created_at: 생성일시

### service_records 테이블
- id: 고유 ID
- customer_id: 고객 ID (외래키)
- service_date: 서비스 날짜/시간
- service_content: 시술 내용
- product_name: 약품명
- payment_type: 결제 타입 (cash/card/transfer)
- amount: 금액
- memo: 메모
- created_at: 생성일시

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# Windows에서 실행
flutter run -d windows

# iOS에서 실행
flutter run -d ios

# Android에서 실행
flutter run -d android
```

## 데이터베이스 위치

### Windows
```
C:\Users\[사용자명]\Documents\HairdressHistory\hairdress_history.db
```

### 백업 파일 위치
```
C:\Users\[사용자명]\Documents\HairdressHistory\backups\hairdress_backup_*.csv
```

## MSSQL 마이그레이션

MSSQL Server에서 데이터를 가져오는 방법은 `MIGRATION_GUIDE.md` 파일을 참고하세요.

## 라이선스

이 프로젝트는 개인 사용 목적으로 개발되었습니다.
