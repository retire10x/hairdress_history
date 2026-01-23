-- ============================================
-- hairdressMVP 데이터베이스 → CSV 추출 스크립트
-- ============================================
-- 간단 사용법:
-- 1. SSMS에서 hairdressMVP 데이터베이스 선택
-- 2. 이 쿼리 실행 (F5)
-- 3. 결과 우클릭 → "다른 이름으로 결과 저장..." → CSV 선택
-- 4. 인코딩: UTF-8 선택
-- 5. Flutter 앱에서 "복원" 버튼으로 CSV 파일 선택
-- ============================================

USE hairdressMVP;
GO

-- 통합 CSV 파일 생성 (고객 + 서비스 기록)
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

-- ============================================
-- 참고: 테이블 구조 확인
-- ============================================
-- Customers 테이블: Id, Name, Phone
-- Service 테이블: Id, CustomerId, Date, Contents, Sales, PayType, Pay, Remarks
-- ============================================
