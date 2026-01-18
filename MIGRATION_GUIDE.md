# MSSQL → Flutter SQLite 마이그레이션 가이드

## 개요
MSSQL Server 데이터를 Flutter SQLite 앱으로 마이그레이션하는 가이드입니다.
**하나의 CSV 파일**에 고객 데이터와 서비스 기록을 모두 포함하여 백업/복원합니다.

## CSV 파일 형식

### 통합 CSV 파일 구조
하나의 CSV 파일에 두 가지 타입의 데이터를 포함합니다:
- 각 행의 첫 번째 컬럼이 타입을 나타냅니다: `CUSTOMER` 또는 `SERVICE_RECORD`
- 첫 번째 행은 헤더입니다

### CSV 파일 예시
```csv
TYPE,id,name,phone,memo,created_at
CUSTOMER,1,홍길동,010-1234-5678,,2024-12-01 10:00:00
CUSTOMER,2,김철수,010-9876-5432,,2024-12-01 10:00:00
TYPE,id,customer_id,service_date,service_content,product_name,payment_type,amount,memo,created_at
SERVICE_RECORD,1,1,2024-01-15 14:30:00,컷트,샴푸A,cash,30000,정기시술,2024-12-01 10:00:00
SERVICE_RECORD,2,1,2024-02-15 15:00:00,펌,펌약B,card,50000,,2024-12-01 10:00:00
SERVICE_RECORD,3,2,2024-03-10 16:00:00,염색,염색약C,transfer,80000,첫방문,2024-12-01 10:00:00
```

**주의**: `TYPE` 헤더 행이 각 섹션 시작 전에 나타납니다.

---

## 1. MSSQL에서 데이터 추출

### 1.1 통합 CSV 파일 생성 SQL 쿼리

#### 방법 1: UNION ALL 사용 (권장)
```sql
-- 하나의 쿼리로 통합 CSV 생성
SELECT 
    'CUSTOMER' AS TYPE,
    CAST(Id AS VARCHAR) AS id,
    Name AS name,
    ISNULL(Phone, '') AS phone,
    '' AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at,
    NULL AS customer_id,
    NULL AS service_date,
    NULL AS service_content,
    NULL AS product_name,
    NULL AS payment_type,
    NULL AS amount
FROM 
    Customers

UNION ALL

SELECT 
    'SERVICE_RECORD' AS TYPE,
    CAST(s.Id AS VARCHAR) AS id,
    NULL AS name,
    NULL AS phone,
    ISNULL(s.Remarks, '') AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at,
    CAST(s.CustomerId AS VARCHAR) AS customer_id,
    CONVERT(VARCHAR, s.Date, 120) AS service_date,
    s.Contents AS service_content,
    ISNULL(s.Sales, '') AS product_name,
    CASE 
        WHEN s.PayType = '현금' THEN 'cash'
        WHEN s.PayType = '카드' THEN 'card'
        WHEN s.PayType IN ('송금', '계좌이체', '이체', '무통장입금') THEN 'transfer'
        ELSE 'cash'
    END AS payment_type,
    CAST(s.Pay AS VARCHAR) AS amount
FROM 
    Service s
WHERE 
    s.CustomerId IN (SELECT Id FROM Customers)  -- 고아 레코드 제외
ORDER BY 
    TYPE, id;
```

#### 방법 2: 두 개의 쿼리로 생성 후 수동 병합
1. **고객 데이터 쿼리**
```sql
SELECT 
    'CUSTOMER' AS TYPE,
    CAST(Id AS VARCHAR) AS id,
    Name AS name,
    ISNULL(Phone, '') AS phone,
    '' AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at
FROM 
    Customers
ORDER BY 
    Id;
```

2. **서비스 기록 쿼리**
```sql
SELECT 
    'SERVICE_RECORD' AS TYPE,
    CAST(s.Id AS VARCHAR) AS id,
    CAST(s.CustomerId AS VARCHAR) AS customer_id,
    CONVERT(VARCHAR, s.Date, 120) AS service_date,
    s.Contents AS service_content,
    ISNULL(s.Sales, '') AS product_name,
    CASE 
        WHEN s.PayType = '현금' THEN 'cash'
        WHEN s.PayType = '카드' THEN 'card'
        WHEN s.PayType IN ('송금', '계좌이체', '이체', '무통장입금') THEN 'transfer'
        ELSE 'cash'
    END AS payment_type,
    CAST(s.Pay AS VARCHAR) AS amount,
    ISNULL(s.Remarks, '') AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at
FROM 
    Service s
WHERE 
    s.CustomerId IN (SELECT Id FROM Customers)
ORDER BY 
    s.CustomerId, s.Date DESC;
```

3. **수동 병합**
   - 두 결과를 Excel에서 열기
   - 첫 번째 쿼리 결과 아래에 두 번째 쿼리 결과 붙여넣기
   - CSV로 저장

---

## 2. CSV 내보내기 방법

### SSMS에서 CSV 내보내기
1. SQL Server Management Studio (SSMS) 실행
2. 위 쿼리 실행
3. 결과를 우클릭 → "다른 이름으로 결과 저장..."
4. 파일 형식: **CSV (쉼표로 구분)(*.csv)** 선택
5. 파일명: `hairdress_backup_YYYYMMDD.csv` (예: `hairdress_backup_20241201.csv`)
6. **중요**: 인코딩을 **UTF-8** 또는 **UTF-8 with BOM**으로 선택
   - SSMS 버전에 따라 인코딩 옵션이 다를 수 있음
   - 한글이 깨지면 다른 인코딩으로 시도 (앱에서 자동 감지)
7. 저장 위치: 쉽게 찾을 수 있는 위치 (예: 바탕화면 또는 Documents 폴더)

**참고**: SSMS에서 UTF-8 옵션이 없으면:
- Excel로 내보낸 후 "다른 이름으로 저장" → CSV → 인코딩: UTF-8 선택
- 또는 앱의 복원 기능이 자동으로 인코딩을 감지하므로 CP949/EUC-KR로 내보내도 됨

---

## 3. 필드 매핑 테이블

### 3.1 Customer 테이블 매핑

| MSSQL 필드 | Flutter 필드 | 변환 규칙 |
|-----------|-------------|----------|
| Id | id | 직접 매핑 (문자열로 변환) |
| Name | name | 직접 매핑 |
| Phone | phone | 직접 매핑 (NULL → 빈 문자열) |
| (없음) | memo | 빈 문자열로 설정 |
| (없음) | created_at | 현재 시간으로 설정 |

### 3.2 Service 테이블 매핑

| MSSQL 필드 | Flutter 필드 | 변환 규칙 |
|-----------|-------------|----------|
| Id | id | 직접 매핑 (문자열로 변환) |
| CustomerId | customer_id | 직접 매핑 (문자열로 변환) |
| Date | service_date | `CONVERT(VARCHAR, Date, 120)` 형식 |
| Contents | service_content | 직접 매핑 |
| Sales | product_name | 직접 매핑 (NULL → 빈 문자열) |
| PayType | payment_type | 문자열 → enum 변환 (아래 표 참조) |
| Pay | amount | 직접 매핑 (문자열로 변환) |
| Remarks | memo | 직접 매핑 (NULL → 빈 문자열) |
| (없음) | created_at | 현재 시간으로 설정 |

### 3.3 PayType 변환 규칙

| MSSQL PayType 값 | Flutter PaymentType |
|-----------------|---------------------|
| '현금' | cash |
| '카드' | card |
| '송금', '계좌이체', '이체', '무통장입금' | transfer |
| 기타 (NULL 포함) | cash (기본값) |

---

## 4. Flutter 앱에서 사용

### 4.1 백업 기능
- 앱에서 "백업" 버튼 클릭
- 하나의 CSV 파일로 저장
- 파일명: `hairdress_backup_YYYYMMDD_HHMMSS.csv`
- 저장 위치: `Documents/HairdressHistory/backups/`

### 4.2 복원 기능
- 앱에서 "복원" 버튼 클릭
- CSV 파일 선택
- MSSQL에서 추출한 파일도 동일하게 복원 가능
- 기존 데이터 덮어쓰기 또는 병합 옵션

### 4.3 마이그레이션 절차
1. MSSQL에서 위 쿼리로 CSV 파일 생성
2. Flutter 앱 실행
3. "복원" 버튼 클릭
4. 생성한 CSV 파일 선택
5. 복원 완료 확인

---

## 5. 데이터 검증 및 주의사항

### 5.1 필수 검증 항목

#### Customer 데이터
- ✅ `name`은 필수 (NULL 또는 빈 문자열 불가)
- ✅ `phone`은 빈 문자열 가능 (Flutter에서는 선택 필드)
- ✅ `id`는 고유해야 함

#### Service 데이터
- ✅ `customer_id`는 Customer 테이블에 존재해야 함 (외래키)
- ✅ `service_content`는 필수 (NULL 또는 빈 문자열 불가)
- ✅ `payment_type`은 'cash', 'card', 'transfer' 중 하나여야 함
- ✅ `amount`는 0 이상의 정수여야 함
- ✅ `service_date`는 유효한 날짜 형식이어야 함 (`YYYY-MM-DD HH:MM:SS`)

### 5.2 데이터 정리 작업 (선택)

마이그레이션 전에 MSSQL에서 데이터를 정리하는 것을 권장합니다:

```sql
-- 1. 중복 고객 확인
SELECT Name, Phone, COUNT(*) AS cnt
FROM Customers
GROUP BY Name, Phone
HAVING COUNT(*) > 1;

-- 2. 고아 서비스 기록 확인 (고객이 없는 서비스 기록)
SELECT s.*
FROM Service s
LEFT JOIN Customers c ON s.CustomerId = c.Id
WHERE c.Id IS NULL;

-- 3. NULL 또는 빈 문자열인 필수 필드 확인
SELECT * FROM Customers WHERE Name IS NULL OR Name = '';
SELECT * FROM Service WHERE Contents IS NULL OR Contents = '';
```

---

## 6. CSV 파일 형식 요구사항

### 6.1 인코딩
- **UTF-8 with BOM** 또는 **UTF-8** 사용
- 한글이 깨지지 않도록 주의

### 6.2 구분자
- 쉼표(`,`) 사용
- 텍스트 필드에 쉼표가 포함된 경우 큰따옴표(`"`)로 감싸기

### 6.3 날짜 형식
- 형식: `YYYY-MM-DD HH:MM:SS`
- 예: `2024-01-15 14:30:00`

### 6.4 NULL 값
- 빈 문자열(`""`)로 표시

### 6.5 타입 구분
- 각 행의 첫 번째 컬럼이 `CUSTOMER` 또는 `SERVICE_RECORD`
- 각 섹션 시작 전에 `TYPE` 헤더 행 포함 (선택사항)

---

## 7. 체크리스트

### 마이그레이션 전 확인사항
- [ ] MSSQL 데이터베이스 백업 완료
- [ ] 통합 CSV 파일 생성 및 검증
- [ ] CSV 파일 인코딩이 UTF-8인지 확인
- [ ] CSV 파일에 TYPE 컬럼이 포함되어 있는지 확인
- [ ] Flutter 앱의 기존 데이터 백업 (있는 경우)
- [ ] PayType 값이 올바르게 변환되는지 확인

### 마이그레이션 후 확인사항
- [ ] 고객 수가 일치하는지 확인
- [ ] 서비스 기록 수가 일치하는지 확인
- [ ] 샘플 데이터로 내용이 올바른지 확인
- [ ] 외래키 관계가 올바른지 확인 (고객 선택 시 서비스 기록 표시)

---

## 8. 문제 해결

### 8.1 한글 깨짐
- **앱에서 자동으로 여러 인코딩을 시도합니다** (UTF-8, CP949, EUC-KR)
- 그래도 깨지면:
  1. Excel에서 CSV 파일 열기
  2. "다른 이름으로 저장" → CSV 형식 선택
  3. 인코딩: **UTF-8** 또는 **UTF-8 with BOM** 선택
  4. 저장 후 다시 복원 시도
- SSMS에서 내보낼 때 인코딩을 UTF-8로 선택하는 것이 가장 좋습니다

### 8.2 날짜 형식 오류
- SQL 쿼리에서 `CONVERT(VARCHAR, Date, 120)` 사용하여 표준 형식으로 변환

### 8.3 PayType 변환 오류
- MSSQL의 PayType 값을 확인하고 쿼리의 CASE 문 수정
- Flutter 앱에서 알 수 없는 값은 'cash'로 기본 처리

### 8.4 외래키 오류
- service_records의 customer_id가 customers의 id와 일치하는지 확인
- 고아 레코드 제거 (위 SQL 쿼리에 WHERE 절 포함됨)

### 8.5 TYPE 컬럼 누락
- CSV 파일의 첫 번째 컬럼이 TYPE인지 확인
- 수동으로 추가: Excel에서 첫 번째 컬럼에 'CUSTOMER' 또는 'SERVICE_RECORD' 입력

---

## 9. 완전한 SQL 쿼리 (복사용)

### 통합 쿼리 (권장)
```sql
-- 하나의 쿼리로 통합 CSV 생성
SELECT 
    'CUSTOMER' AS TYPE,
    CAST(Id AS VARCHAR) AS id,
    Name AS name,
    ISNULL(Phone, '') AS phone,
    '' AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at,
    NULL AS customer_id,
    NULL AS service_date,
    NULL AS service_content,
    NULL AS product_name,
    NULL AS payment_type,
    NULL AS amount
FROM 
    Customers

UNION ALL

SELECT 
    'SERVICE_RECORD' AS TYPE,
    CAST(s.Id AS VARCHAR) AS id,
    NULL AS name,
    NULL AS phone,
    ISNULL(s.Remarks, '') AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at,
    CAST(s.CustomerId AS VARCHAR) AS customer_id,
    CONVERT(VARCHAR, s.Date, 120) AS service_date,
    s.Contents AS service_content,
    ISNULL(s.Sales, '') AS product_name,
    CASE 
        WHEN s.PayType = '현금' THEN 'cash'
        WHEN s.PayType = '카드' THEN 'card'
        WHEN s.PayType IN ('송금', '계좌이체', '이체', '무통장입금') THEN 'transfer'
        ELSE 'cash'
    END AS payment_type,
    CAST(s.Pay AS VARCHAR) AS amount
FROM 
    Service s
WHERE 
    s.CustomerId IN (SELECT Id FROM Customers)
ORDER BY 
    TYPE, id;
```

---

## 10. 연락처 및 참고

- 문서 작성일: 2024-12-01
- 버전: 2.0 (통합 CSV 형식)
- 백업/복원 형식: 단일 CSV 파일 (TYPE 컬럼 포함)