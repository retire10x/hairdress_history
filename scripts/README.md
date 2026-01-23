# 스크립트 가이드

## 간단한 마이그레이션 (3단계)

### 1. SQL 쿼리 실행 → CSV 추출

1. SSMS에서 `hairdressMVP` 데이터베이스 선택
2. `export_hairdressMVP_to_csv.sql` 파일 열기
3. 쿼리 실행 (F5)
4. 결과 우클릭 → "다른 이름으로 결과 저장..." → CSV 선택
5. 인코딩: **UTF-8** 선택
6. 저장

### 2. Flutter 앱에서 복원

1. 앱 실행 → "백업/복원" 버튼 클릭
2. "데이터 복원" 버튼 클릭
3. CSV 파일 선택
4. 완료!

### 3. 데이터 확인

- 고객 수 확인
- 서비스 기록 수 확인
- 샘플 데이터 확인
- 끝!

---

## 더 간단한 가이드

👉 **[SIMPLE_MIGRATION.md](SIMPLE_MIGRATION.md)** - 3단계로 끝내는 초간단 가이드

## 상세 가이드 (필요시)

👉 **[MIGRATION_GUIDE.md](../docs/MIGRATION_GUIDE.md)** - 상세한 마이그레이션 가이드
