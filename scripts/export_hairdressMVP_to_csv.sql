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
    CAST(Customer_Id AS VARCHAR) AS id,
    Customer_Name AS name,
    ISNULL(Customer_Phone, '') AS phone,
    '' AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at,
    NULL AS customer_id,
    NULL AS service_date,
    NULL AS service_content,
    NULL AS product_name,
    NULL AS payment_type,
    NULL AS amount
FROM 
    customer

UNION ALL

SELECT 
    'SERVICE_RECORD' AS TYPE,
    CAST(s.Service_Id AS VARCHAR) AS id,
    NULL AS name,
    NULL AS phone,
    ISNULL(s.Service_Remarks, '') AS memo,
    CONVERT(VARCHAR, GETDATE(), 120) AS created_at,
    CAST(s.CustomerId AS VARCHAR) AS customer_id,
    CONVERT(VARCHAR, s.Service_Date, 120) AS service_date,
    s.Service_Contents AS service_content,
    ISNULL(s.Service_Sales, '') AS product_name,
    CASE 
        WHEN s.Service_PayType = '현금' THEN 'cash'
        WHEN s.Service_PayType = '카드' THEN 'card'
        WHEN s.Service_PayType IN ('송금', '계좌이체', '이체', '무통장입금') THEN 'transfer'
        ELSE 'cash'
    END AS payment_type,
    CAST(s.Service_Pay AS VARCHAR) AS amount
FROM 
    customerService s
WHERE 
    s.CustomerId IN (SELECT Customer_Id FROM customer)  -- 고아 레코드 제외
ORDER BY 
    TYPE, id;

-- ============================================
-- 참고: 테이블 구조 확인
-- ============================================
-- customer 테이블: Customer_Id, Customer_Name, Customer_Phone, Customer_Picture
-- customerService 테이블: Service_Id, CustomerId, Service_Date, Service_Contents, 
--                        Service_PayType, Service_Pay, Service_Remarks, Service_Sales
-- ============================================
