# 간단한 마이그레이션 가이드

## 3단계로 끝내기

### 1단계: SQL 쿼리 실행해서 CSV 추출

**SQL Server Management Studio (SSMS)에서:**

1. `hairdressMVP` 데이터베이스 선택
2. 아래 쿼리 복사해서 실행

```sql
USE hairdressMVP;

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
FROM Customers

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
FROM Service s
WHERE s.CustomerId IN (SELECT Id FROM Customers)
ORDER BY TYPE, id;
```

3. 결과를 **우클릭** → **"다른 이름으로 결과 저장..."**
4. 파일 형식: **CSV** 선택
5. 인코딩: **UTF-8** 선택 (한글 깨짐 방지)
6. 저장

### 2단계: Flutter 앱에서 복원

1. **hairdress_history 앱 실행**
2. 상단 **"백업/복원"** 버튼 클릭
3. **"데이터 복원"** 버튼 클릭
4. 위에서 저장한 **CSV 파일 선택**
5. 복원 완료!

### 3단계: 데이터 확인

- 고객 수 확인
- 서비스 기록 수 확인
- 샘플 데이터 몇 개 확인
- 끝!

---

## 문제 발생 시

### 한글이 깨지면?
- CSV 파일을 Excel로 열어서 다시 저장
- "다른 이름으로 저장" → CSV → 인코딩: **UTF-8** 선택

### 복원이 안 되면?
- CSV 파일의 첫 번째 컬럼이 `TYPE`인지 확인
- `CUSTOMER` 또는 `SERVICE_RECORD`로 시작하는지 확인

---

**그게 전부입니다!** 🎉
